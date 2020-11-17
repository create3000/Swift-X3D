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
