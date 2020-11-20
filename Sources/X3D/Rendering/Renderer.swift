//
//  Renderer.swift
//  X3D
//
//  Created by Holger Seelig on 08.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

internal final class Renderer
{
   // Public properties
   
   internal final var primitives = (points: 0, lines: 0, triangles: 0, opaqueShapes: 0, transparentShapes: 0)
   
   // Properties
   
   internal private(set) final unowned var browser : X3DBrowser
   internal final unowned var layerNode            : X3DLayerNode!
   internal final unowned var commandBuffer        : MTLCommandBuffer!
   
   internal init (for browser : X3DBrowser)
   {
      self .browser = browser
   }

   // Matrices
   
   internal final var              viewport         = [Vector4i] ()
   internal private(set) final var projectionMatrix = MatrixStack ()
   internal private(set) final var viewViewMatrix   = MatrixStack ()
   internal private(set) final var modelViewMatrix  = MatrixStack ()
   
   // Stacks and arrays
   
   internal final var layerNumber   = 0
   internal final var fogs          = [FogContainer] ()
   internal final var globalLights  = [LightContainer] ()
   internal final var localLights   = [LightContainer] ()
   internal final var collisions    = [Collision] ()

   // Light sources
   
   private final var lightSourcesArray = [X3DLightSources] ()
   
   internal var lightSources : X3DLightSources
   {
      if layerNumber < lightSourcesArray .count
      {
         return lightSourcesArray [layerNumber]
      }
      else
      {
         let lightSources = X3DLightSources (browser: browser)
         
         lightSourcesArray .append (lightSources)
         
         return lightSources
      }
   }
   
   // Collision context object handling
   
   private final var collisionShapes   = [CollisionContext] ()
   private final var numCollsionShapes = 0

   internal final func addCollisionShape (_ shapeNode : X3DShapeNode)
   {
      let bbox  = modelViewMatrix .top * shapeNode .bbox
      let depth = bbox .size .z / 2
      let min   = bbox .center .z - depth
      
      // Return if the model is completely behind the front plane.
      
      guard min < 0 else { return }
      
      // Select collision context.

      var collisionContext : CollisionContext!

      do
      {
         if numCollsionShapes < collisionShapes .count
         {
            collisionContext = collisionShapes [numCollsionShapes]
         }
         else
         {
            collisionContext = CollisionContext (renderer: self)
            
            collisionShapes .append (collisionContext!)
         }
         
         numCollsionShapes += 1
      }
      
      // Set collision context properties.
      
      let uniforms = collisionContext .uniforms

      collisionContext .shapeNode        = shapeNode
      collisionContext .collisions       = collisions
      uniforms .pointee .viewport        = viewport .last!
      uniforms .pointee .modelViewMatrix = modelViewMatrix .top
   }
   
   internal final func beginCollision ()
   {
      numCollsionShapes = 0
   }
   
   internal final func endCollision ()
   {

   }

   internal final func collision ()
   {
      collide ()
      gravite ()
   }
   
   private final func collide ()
   {
      
   }
   
   private final var speed : Float = 0
   
   private final func gravite ()
   {
      guard browser .viewerNode is WalkViewer else { return }
      
      let navigationInfoNode  = layerNode .navigationInfoNode
      let viewpointNode       = layerNode .viewpointNode
      let collisionRadius     = navigationInfoNode .collisionRadius
      let nearValue           = navigationInfoNode .nearValue
      let avatarHeight        = navigationInfoNode .avatarHeight
      let stepHeight          = navigationInfoNode .stepHeight

      // Reshape viewpoint for gravite.

      let projectionMatrix = Camera .ortho (left: -collisionRadius,
                                            right: collisionRadius,
                                            bottom: -collisionRadius,
                                            top: collisionRadius,
                                            nearValue: nearValue,
                                            farValue: max (collisionRadius * 2, avatarHeight * 2))
      
      // Transform viewpoint to look down the up vector

      let upVector                    = viewpointNode .upVector
      let down                        = Rotation4f (from: .zAxis, to: upVector)
      var cameraSpaceProjectionMatrix = viewpointNode .modelMatrix

      cameraSpaceProjectionMatrix = cameraSpaceProjectionMatrix .translate (viewpointNode .userPosition)
      cameraSpaceProjectionMatrix = cameraSpaceProjectionMatrix .rotate (down)
      cameraSpaceProjectionMatrix = cameraSpaceProjectionMatrix .inverse
      cameraSpaceProjectionMatrix = projectionMatrix * cameraSpaceProjectionMatrix * viewpointNode .cameraSpaceMatrix
 
      self .projectionMatrix .push (cameraSpaceProjectionMatrix)

      var distance = -depth (projectionMatrix)

      self .projectionMatrix .pop ()

      // Gravite or step up

      let up = Rotation4f (from: .yAxis, to: upVector)

      distance -= avatarHeight

      if distance > 0
      {
         // Gravite and fall down to the floor.

         let currentFrameRate = Float (speed != 0 ? browser .currentFrameRate : 1000000)

         speed -= browser .getBrowserOptions () .Gravity / currentFrameRate

         var translation = speed / currentFrameRate

         if translation < -distance
         {
            // The ground is reached.
            translation = -distance
            speed       = 0
         }

         layerNode .viewpointNode .positionOffset += up * Vector3f (0, translation, 0)
      }
      else
      {
         speed    = 0
         distance = -distance

         if distance > 0.01 && distance < stepHeight
         {
            // Step up
            let translation = constrain (up * Vector3f (0, distance, 0), false)

            layerNode .viewpointNode .positionOffset += translation
         }
      }
   }
   
   internal final func constrain (_ translation : Vector3f, _ stepBack : Bool) -> Vector3f
   {
      var distance = self .distance (translation)

      // Constrain translation when the viewer collides with an obstacle.

      distance -= layerNode .navigationInfoNode .collisionRadius

      if distance > 0
      {
         // Move.

         let length = simd_length (translation)

         if length > distance
         {
            // Collision, the avatar would intersect with the obstacle.

            return normalize (translation) * distance
         }

         // Everything is fine.

         return translation
      }

      // Collision, the avatar is already within an obstacle.

      if stepBack
      {
         return constrain (normalize (translation) * distance, false)
      }

      return .zero
   }
   
   private final func distance (_ direction : Vector3f) -> Float
   {
      // Determine width and height of camera.

      let viewpointNode      = layerNode .viewpointNode
      let navigationInfoNode = layerNode .navigationInfoNode
      let collisionRadius    = navigationInfoNode .collisionRadius
      let bottom             = navigationInfoNode .stepHeight - navigationInfoNode .avatarHeight
      let nearValue          = navigationInfoNode .nearValue
      let avatarHeight       = navigationInfoNode .avatarHeight

      // Reshape camera.

      let projectionMatrix = Camera .ortho (left: -collisionRadius,
                                            right: collisionRadius,
                                            bottom: min (bottom, -collisionRadius),
                                            top: collisionRadius, nearValue: nearValue,
                                            farValue: max (collisionRadius * 2, avatarHeight * 2))

      // Translate camera to user position and to look in the direction of the @a direction.

      let localOrientation = viewpointNode .getOrientation () * viewpointNode .orientation .inverse
      var rotation         = localOrientation * Rotation4f (from: .zAxis, to: -direction)

      // The viewer is alway a straight box depending on the upVector.
      rotation = viewpointNode .straightenHorizon (rotation) * rotation

      var cameraSpaceProjectionMatrix = viewpointNode .modelMatrix
      
      cameraSpaceProjectionMatrix = cameraSpaceProjectionMatrix .translate (viewpointNode .userPosition)
      cameraSpaceProjectionMatrix = cameraSpaceProjectionMatrix .rotate (rotation)
      cameraSpaceProjectionMatrix = cameraSpaceProjectionMatrix .inverse
      cameraSpaceProjectionMatrix = projectionMatrix * cameraSpaceProjectionMatrix * viewpointNode .cameraSpaceMatrix

      // Render depth.

      self .projectionMatrix .push (cameraSpaceProjectionMatrix)

      let distance = depth (projectionMatrix)

      self .projectionMatrix .pop ()

      return -distance
   }
   
   private final lazy var depthBuffer : DepthBuffer = { DepthBuffer (browser, width: 16, height: 16) }()
  
   private final func depth (_ projectionMatrix : Matrix4f) -> Float
   {
      depth ()
      
      return depthBuffer .depth (projectionMatrix)
   }
   
   private final func depth ()
   {
      guard let commandBuffer = browser .commandQueue .makeCommandBuffer () else { return }
      
      // Prepare render pass, ie. create render encoder with appropriate settings.
      
      let renderPassDescriptor = MTLRenderPassDescriptor ()
      
      renderPassDescriptor .colorAttachments [0] .texture    = depthBuffer .colorTexture
      renderPassDescriptor .colorAttachments [0] .loadAction = .clear
      renderPassDescriptor .colorAttachments [0] .clearColor = MTLClearColor (red: 0, green: 0, blue: 0, alpha: 0)

      renderPassDescriptor .depthAttachment .texture     = depthBuffer .depthTexture
      renderPassDescriptor .depthAttachment .clearDepth  = 1
      renderPassDescriptor .depthAttachment .loadAction  = .clear
      renderPassDescriptor .depthAttachment .storeAction = .store
 
      guard let renderEncoder = commandBuffer .makeRenderCommandEncoder (descriptor: renderPassDescriptor) else { return }
      
      renderEncoder .setDepthStencilState   (browser .depthStencilState [true])
      renderEncoder .setRenderPipelineState (browser .depthPipelineState)
      renderEncoder .setCullMode (.none)

//      let surface = browser .viewport

      for collisionContext in collisionShapes [..<numCollsionShapes]
      {
//         let rectangle = collisionContext .uniforms .pointee .viewport
//
//         renderEncoder .setViewport (MTLViewport (originX: Double (rectangle [0]),
//                                                  originY: Double (surface [3] - rectangle [1] - rectangle [3]),
//                                                  width:   Double (rectangle [2]),
//                                                  height:  Double (rectangle [3]),
//                                                  znear:   0,
//                                                  zfar:    1))
         
         collisionContext .uniforms .pointee .projectionMatrix = projectionMatrix .top

         collisionContext .shapeNode .render (collisionContext, renderEncoder)
      }
      
      renderEncoder .endEncoding ()
      
      depthBuffer .blit (commandBuffer)

      commandBuffer .commit ()
      commandBuffer .waitUntilCompleted ()
   }

   // Render context objects handling
   
   private final var opaqueShapes           = [RenderContext] ()
   private final var transparentShapes      = [RenderContext] ()
   private final var firstOpaqueShape       = 0
   private final var firstTransparentShape  = 0
   private final var numOpaqueShapes        = 0
   private final var numTransparentShapes   = 0

   internal final func addRenderShape (_ shapeNode : X3DShapeNode)
   {
      let bbox  = modelViewMatrix .top * shapeNode .bbox
      let depth = bbox .size .z / 2
      let min   = bbox .center .z - depth
      
      // Return if the model is completely behind the front plane.
      
      guard min < 0 else { return }
      
//      // Return if the model does not intersect with the view volume.
//
//      let viewVolume = viewVolumes .top
//
//      guard viewVolume .intersects (abs (bbox .size) / 2, bbox .center) else
//      {
//         return
//      }
      
      // Select render context.
      
      var renderContext : RenderContext!

      if shapeNode .isTransparent
      {
         if numTransparentShapes < transparentShapes .count
         {
            renderContext = transparentShapes [numTransparentShapes]
         }
         else
         {
            renderContext = RenderContext (renderer: self, isTransparent: true)
            
            transparentShapes .append (renderContext!)
         }
         
         numTransparentShapes += 1
      }
      else
      {
         if numOpaqueShapes < opaqueShapes .count
         {
            renderContext = opaqueShapes [numOpaqueShapes]
         }
         else
         {
            renderContext = RenderContext (renderer: self, isTransparent: false)
            
            opaqueShapes .append (renderContext!)
         }
    
         numOpaqueShapes += 1
      }
      
      // Set render context properties.
      
      let uniforms = renderContext .uniforms

      renderContext .shapeNode            = shapeNode
      renderContext .fogObject            = fogs .last
      renderContext .localLights          = localLights
      renderContext .distance             = bbox .center .z
      uniforms .pointee .viewport         = viewport .last!
      uniforms .pointee .projectionMatrix = projectionMatrix .top
      uniforms .pointee .modelViewMatrix  = modelViewMatrix .top
      uniforms .pointee .normalMatrix     = modelViewMatrix .top .submatrix .transpose .inverse
   }
   
   internal final func beginRender ()
   {
      firstOpaqueShape      = 0
      firstTransparentShape = 0
      numOpaqueShapes       = 0
      numTransparentShapes  = 0
      primitives            = (0, 0, 0, 0,  0)
   }
   
   internal final func endRender ()
   {
      primitives .opaqueShapes      += numOpaqueShapes
      primitives .transparentShapes += numTransparentShapes
   }

   internal final func render ()
   {
      // Prepare render pass, ie. create render encoder with appropriate settings.
      
      guard let renderPassDescriptor = browser .currentRenderPassDescriptor else { return }
      
      renderPassDescriptor .depthAttachment .loadAction      = .clear
      renderPassDescriptor .depthAttachment .clearDepth      = 1
      renderPassDescriptor .colorAttachments [0] .loadAction = .load

      guard let renderEncoder = commandBuffer! .makeRenderCommandEncoder (descriptor: renderPassDescriptor) else { return }
      
      // Set default sampler for texture channels 0 and 1.
      renderEncoder .setFragmentSamplerState (browser .defaultSampler, index: 0)
      renderEncoder .setFragmentSamplerState (browser .defaultSampler, index: 1)

      // Render background.
      
      let surface   = browser .viewport
      let rectangle = viewport .first!

      renderEncoder .setViewport (MTLViewport (originX: Double (rectangle [0]),
                                               originY: Double (surface [3] - rectangle [1] - rectangle [3]),
                                               width:   Double (rectangle [2]),
                                               height:  Double (rectangle [3]),
                                               znear:   0,
                                               zfar:    1))

      layerNode .backgroundNode .render (renderer: self, renderEncoder: renderEncoder)
      
      // Set uniforms of global lights.
      
      let lightSources = self .lightSources
      
      for index in 0 ..< globalLights .count
      {
         globalLights [index] .setUniforms (lightSources, index)
      }
      
      renderEncoder .setVertexBuffer   (lightSources .uniformsBuffer, offset: 0, index: 2)
      renderEncoder .setFragmentBuffer (lightSources .uniformsBuffer, offset: 0, index: 2)
      
      // Render opaque nodes.
      
      renderEncoder .setDepthStencilState   (browser .depthStencilState [true])
      renderEncoder .setRenderPipelineState (browser .defaultRenderPipelineState [false]!)
      
      for renderContext in opaqueShapes [firstOpaqueShape ..< numOpaqueShapes]
      {
         let rectangle = renderContext .uniforms .pointee .viewport
         
         renderEncoder .setViewport (MTLViewport (originX: Double (rectangle [0]),
                                                  originY: Double (surface [3] - rectangle [1] - rectangle [3]),
                                                  width:   Double (rectangle [2]),
                                                  height:  Double (rectangle [3]),
                                                  znear:   0,
                                                  zfar:    1))

         renderContext .shapeNode .render (renderContext, renderEncoder)
      }
      
      // Render transparent nodes in stable sorted order.
      
      renderEncoder .setDepthStencilState   (browser .depthStencilState [false])
      renderEncoder .setRenderPipelineState (browser .defaultRenderPipelineState [true]!)
      
      var sortedTransparentShapes = transparentShapes [firstTransparentShape ..< numTransparentShapes]
         
      sortedTransparentShapes .sort { $0 .distance < $1 .distance }
      
      for renderContext in sortedTransparentShapes
      {
         let rectangle = renderContext .uniforms .pointee .viewport
         
         renderEncoder .setViewport (MTLViewport (originX: Double (rectangle [0]),
                                                  originY: Double (surface [3] - rectangle [1] - rectangle [3]),
                                                  width:   Double (rectangle [2]),
                                                  height:  Double (rectangle [3]),
                                                  znear:   0,
                                                  zfar:    1))

         renderContext .shapeNode .render (renderContext, renderEncoder)
      }

      // Finish render pass.
      
      renderEncoder .endEncoding ()
      
      // Clear global objects.
      
      globalLights .removeAll (keepingCapacity: true)
      
      // Advance indices.
      
      firstOpaqueShape      = numOpaqueShapes
      firstTransparentShape = numTransparentShapes
   }
}
