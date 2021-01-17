//
//  X3DBackgroundNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal
import ComplexModule

public class X3DBackgroundNode :
   X3DBindableNode
{
   // Fields

   @MFFloat public final var groundAngle  : [Float]
   @MFColor public final var groundColor  : [Color3f]
   @MFFloat public final var skyAngle     : [Float]
   @MFColor public final var skyColor     : [Color3f] = [.zero]
   @SFFloat public final var transparency : Float = 0
   
   // Properties
   
   @SFBool public final var isHidden : Bool = false
   
   // Sphere properties
   
   private final var sphere = false
   private final var spherePrimitives = [x3d_VertexIn] ()
   private final var spherePrimitivesBuffer : MTLBuffer?
   
   // Cube properties
   
   private final var textureNodes : [X3DTextureNode?] = [nil, nil, nil, nil, nil, nil]
   
   private final var cubePrimitives = [x3d_VertexIn] ()
   private final var cubePrimitivesBuffer : MTLBuffer?

   // Rendering properties
   
   private final var modelMatrix : Matrix4f = .identity
   
   private final var renderer      : Renderer!
   private final var sphereContext : RenderContext!
   private final var cubeContexts  : [RenderContext] = [ ]
   private final var lightSources  : X3DLightSources!

   // Constants
   
   private final let Radius     : Float = 1
   private final let Size       : Float = sqrt (1 / 2)
   private final let uDimension : Int = 20
   
   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DBackgroundNode)
      
      addChildObjects ($isHidden)

      $skyAngle    .unit = .angle
      $groundAngle .unit = .angle
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      renderer      = browser! .renderers .pop ()
      sphereContext = RenderContext (renderer: renderer, isTransparent: true)
      lightSources  = X3DLightSources (browser: browser!)
      
      for _ in 0 ..< 6
      {
         cubeContexts .append (RenderContext (renderer: renderer, isTransparent: true))
      }
      
      addInterest ("buildRectangleOrSphere", X3DBackgroundNode .buildRectangleOrSphere, self)
      
      buildRectangleOrSphere ()
      buildCube ()
   }
   
   // Event handlers
   
   internal final func set_frontTexture (textureNode : X3DTextureNode?)
   {
      set_texture (textureNode, index: 0)
   }
   
   internal final func set_backTexture (textureNode : X3DTextureNode?)
   {
      set_texture (textureNode, index: 1)
   }
   
   internal final func set_leftTexture (textureNode : X3DTextureNode?)
   {
      set_texture (textureNode, index: 2)
   }
   
   internal final func set_rightTexture (textureNode : X3DTextureNode?)
   {
      set_texture (textureNode, index: 3)
   }
   
   internal final func set_topTexture (textureNode : X3DTextureNode?)
   {
      set_texture (textureNode, index: 4)
   }
   
   internal final func set_bottomTexture (textureNode : X3DTextureNode?)
   {
      set_texture (textureNode, index: 5)
   }
   
   private final func set_texture (_ textureNode : X3DTextureNode?, index : Int)
   {
      if textureNode is X3DTexture2DNode || textureNode is MultiTexture
      {
         textureNodes [index] = textureNode
      }
      else
      {
         textureNodes [index] = nil
      }
   }

   // Color sphere
  
   private final func buildRectangleOrSphere ()
   {
      spherePrimitives .removeAll (keepingCapacity: true)
      
      guard transparency < 1 else { return }
      
      let alpha = 1 - clamp (transparency, min: 0, max: 1)
      
      if (groundColor .count == 0 && skyColor .count == 1)
      {
         // Build rectangle.
         sphere = false
         
         // Make uniform color.
         let color = Color4f (skyColor [0], alpha)
         
         // Rectangle's triangle vertices.
         addPrimitive (color: color, point: Vector4f ( 1,  1, 0, 1))
         addPrimitive (color: color, point: Vector4f (-1,  1, 0, 1))
         addPrimitive (color: color, point: Vector4f (-1, -1, 0, 1))
         addPrimitive (color: color, point: Vector4f ( 1,  1, 0, 1))
         addPrimitive (color: color, point: Vector4f (-1, -1, 0, 1))
         addPrimitive (color: color, point: Vector4f ( 1, -1, 0, 1))
      }
      else
      {
         // Build sphere
         
         sphere = true
         
         // Build sky.
         
         if skyColor .count > skyAngle .count
         {
            var vAngle : [Float] = [ ]

            vAngle .append (contentsOf: skyAngle)

            if vAngle .isEmpty || vAngle .first! > 0
            {
               vAngle .insert (0, at: 0)
            }

            let vAngleMax = groundColor .count > groundAngle .count ? Float .pi / 2 : Float .pi

            if vAngle .last! < vAngleMax
            {
               vAngle .append (vAngleMax)
            }

            buildSphere (radius: Radius, vAngle: vAngle, angle: skyAngle, color: skyColor, alpha: alpha, bottom: false)
         }
         
         // Build ground.

         if groundColor .count > groundAngle .count
         {
            var vAngle : [Float] = [ ]

            vAngle .append (contentsOf: groundAngle)
            vAngle .reverse ()

            if vAngle .isEmpty || vAngle .first! < Float .pi / 2
            {
               vAngle .insert (Float .pi / 2, at: 0)
            }

            if vAngle .last! > 0
            {
               vAngle .append (0)
            }

            buildSphere (radius: Radius, vAngle: vAngle, angle: groundAngle, color: groundColor, alpha: alpha, bottom: true)
         }
      }

      spherePrimitivesBuffer = browser! .device! .makeBuffer (bytes: spherePrimitives, length: spherePrimitives .count * MemoryLayout <x3d_VertexIn> .stride, options: [ ])!
   }
   
   private final func buildSphere (radius : Float, vAngle : [Float], angle : [Float], color : [Color3f], alpha : Float, bottom : Bool)
   {
      let vAngleMax  = bottom ? Float .pi / 2 : Float .pi
      let vDimension = vAngle .count - 1
      
      for v in 0 ..< vDimension
      {
         var theta1 = clamp (vAngle [v],     min: 0, max: vAngleMax)
         var theta2 = clamp (vAngle [v + 1], min: 0, max: vAngleMax)

         if (bottom)
         {
            theta1 = Float .pi - theta1
            theta2 = Float .pi - theta2
         }

         let z1 = Complex (length: radius, phase: theta1)
         let z2 = Complex (length: radius, phase: theta2)

         let c1 = Color4f (getColor (theta: vAngle [v],     color: color, angle: angle), alpha)
         let c2 = Color4f (getColor (theta: vAngle [v + 1], color: color, angle: angle), alpha)

         for u in 0 ..< uDimension
         {
            // p4 --- p1
            //  |   / |
            //  | /   |
            // p3 --- p2

            // The last point is the first one.
            let u1 = u < uDimension - 1 ? u + 1 : 0

            // p1, p2
            let phi1 = 2 * Float .pi * (Float (u) / Float (uDimension))
            let y1   = Complex (length: -z1 .imaginary, phase: phi1)
            let y2   = Complex (length: -z2 .imaginary, phase: phi1)

            // p3, p4
            let phi2 = 2 * Float .pi * (Float (u1) / Float (uDimension))
            let y3   = Complex (length: -z2 .imaginary, phase: phi2)
            let y4   = Complex (length: -z1 .imaginary, phase: phi2)

            // Triangle 1 and 2
            
            addPrimitive (color: c1, point: Vector4f (y1 .imaginary, z1 .real, y1 .real, 1))
            addPrimitive (color: c2, point: Vector4f (y3 .imaginary, z2 .real, y3 .real, 1))
            addPrimitive (color: c2, point: Vector4f (y2 .imaginary, z2 .real, y2 .real, 1))
            
            addPrimitive (color: c1, point: Vector4f (y1 .imaginary, z1 .real, y1 .real, 1))
            addPrimitive (color: c1, point: Vector4f (y4 .imaginary, z1 .real, y4 .real, 1))
            addPrimitive (color: c2, point: Vector4f (y3 .imaginary, z2 .real, y3 .real, 1))
         }
      }
   }
   
   private final func getColor (theta : Float, color : [Color3f], angle: [Float]) -> Color3f
   {
      return color [angle .upperBound (value: theta, comp: <)]
   }

   private final func addPrimitive (color : Color4f, point : Vector4f)
   {
      spherePrimitives .append (x3d_VertexIn (fogDepth: 0,
                                              color: color,
                                              texCoords: (.zero, .zero),
                                              normal: .zero,
                                              point: point))
   }
   
   // Texture cube
   
   private final func buildCube ()
   {
      let s = Size
      
      cubePrimitives .removeAll (keepingCapacity: true)
      
      // Front
      addPrimitive (texCoord: Vector4f (1, 1, 0, 1), point: Vector4f ( s,  s, -s, 1))
      addPrimitive (texCoord: Vector4f (0, 1, 0, 1), point: Vector4f (-s,  s, -s, 1))
      addPrimitive (texCoord: Vector4f (0, 0, 0, 1), point: Vector4f (-s, -s, -s, 1))
      addPrimitive (texCoord: Vector4f (1, 1, 0, 1), point: Vector4f ( s,  s, -s, 1))
      addPrimitive (texCoord: Vector4f (0, 0, 0, 1), point: Vector4f (-s, -s, -s, 1))
      addPrimitive (texCoord: Vector4f (1, 0, 0, 1), point: Vector4f ( s, -s, -s, 1))

      // Back
      addPrimitive (texCoord: Vector4f (1, 1, 0, 1), point: Vector4f (-s,  s,  s, 1))
      addPrimitive (texCoord: Vector4f (0, 1, 0, 1), point: Vector4f ( s,  s,  s, 1))
      addPrimitive (texCoord: Vector4f (0, 0, 0, 1), point: Vector4f ( s, -s,  s, 1))
      addPrimitive (texCoord: Vector4f (1, 1, 0, 1), point: Vector4f (-s,  s,  s, 1))
      addPrimitive (texCoord: Vector4f (0, 0, 0, 1), point: Vector4f ( s, -s,  s, 1))
      addPrimitive (texCoord: Vector4f (1, 0, 0, 1), point: Vector4f (-s, -s,  s, 1))

      // Left
      addPrimitive (texCoord: Vector4f (1, 1, 0, 1), point: Vector4f (-s,  s, -s, 1))
      addPrimitive (texCoord: Vector4f (0, 1, 0, 1), point: Vector4f (-s,  s,  s, 1))
      addPrimitive (texCoord: Vector4f (0, 0, 0, 1), point: Vector4f (-s, -s,  s, 1))
      addPrimitive (texCoord: Vector4f (1, 1, 0, 1), point: Vector4f (-s,  s, -s, 1))
      addPrimitive (texCoord: Vector4f (0, 0, 0, 1), point: Vector4f (-s, -s,  s, 1))
      addPrimitive (texCoord: Vector4f (1, 0, 0, 1), point: Vector4f (-s, -s, -s, 1))

      // Right
      addPrimitive (texCoord: Vector4f (1, 1, 0, 1), point: Vector4f ( s,  s,  s, 1))
      addPrimitive (texCoord: Vector4f (0, 1, 0, 1), point: Vector4f ( s,  s, -s, 1))
      addPrimitive (texCoord: Vector4f (0, 0, 0, 1), point: Vector4f ( s, -s, -s, 1))
      addPrimitive (texCoord: Vector4f (1, 1, 0, 1), point: Vector4f ( s,  s,  s, 1))
      addPrimitive (texCoord: Vector4f (0, 0, 0, 1), point: Vector4f ( s, -s, -s, 1))
      addPrimitive (texCoord: Vector4f (1, 0, 0, 1), point: Vector4f ( s, -s,  s, 1))

      // Top
      addPrimitive (texCoord: Vector4f (1, 1, 0, 1), point: Vector4f ( s, s,  s, 1))
      addPrimitive (texCoord: Vector4f (0, 1, 0, 1), point: Vector4f (-s, s,  s, 1))
      addPrimitive (texCoord: Vector4f (0, 0, 0, 1), point: Vector4f (-s, s, -s, 1))
      addPrimitive (texCoord: Vector4f (1, 1, 0, 1), point: Vector4f ( s, s,  s, 1))
      addPrimitive (texCoord: Vector4f (0, 0, 0, 1), point: Vector4f (-s, s, -s, 1))
      addPrimitive (texCoord: Vector4f (1, 0, 0, 1), point: Vector4f ( s, s, -s, 1))

      // Bottom
      addPrimitive (texCoord: Vector4f (1, 1, 0, 1), point: Vector4f ( s, -s, -s, 1))
      addPrimitive (texCoord: Vector4f (0, 1, 0, 1), point: Vector4f (-s, -s, -s, 1))
      addPrimitive (texCoord: Vector4f (0, 0, 0, 1), point: Vector4f (-s, -s,  s, 1))
      addPrimitive (texCoord: Vector4f (1, 1, 0, 1), point: Vector4f ( s, -s, -s, 1))
      addPrimitive (texCoord: Vector4f (0, 0, 0, 1), point: Vector4f (-s, -s,  s, 1))
      addPrimitive (texCoord: Vector4f (1, 0, 0, 1), point: Vector4f ( s, -s,  s, 1))

      cubePrimitivesBuffer = browser! .device! .makeBuffer (bytes: cubePrimitives, length: cubePrimitives .count * MemoryLayout <x3d_VertexIn> .stride, options: [ ])!
   }
   
   func addPrimitive (texCoord : Vector4f, point : Vector4f)
   {
      cubePrimitives .append (x3d_VertexIn (fogDepth: 0,
                                            color: Color4f .one,
                                            texCoords: (texCoord, texCoord),
                                            normal: .zero,
                                            point: point))
   }
   
   // Traverse camera

   internal final override func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      renderer .layerNode! .backgroundList .append (node: self)
      
      modelMatrix = renderer .modelViewMatrix .top
   }
   
   // Rendering

   internal final func render (renderer : Renderer, renderEncoder : MTLRenderCommandEncoder)
   {
      guard !isHidden else { return }
      
      let viewport        = renderer .viewport .first!
      let farValue        = ViewVolume .unProjectPoint (0, 0, 1, inverse (renderer .projectionMatrix .top), viewport) .z * -0.8
      let rotation        = decompose_transformation_matrix (renderer .viewViewMatrix .top * modelMatrix) .rotation
      let modelViewMatrix = compose_transformation_matrix (rotation: rotation, scale: Vector3f (repeating: farValue))
      
      renderSphere (renderer, renderEncoder, modelViewMatrix)
      renderCube   (renderer, renderEncoder, modelViewMatrix)
   }
   
   private final func renderSphere (_ renderer : Renderer,
                                    _ renderEncoder : MTLRenderCommandEncoder,
                                    _ modelViewMatrix : Matrix4f)
   {
      guard transparency < 1 else { return }
      
      // Set render pipeline states.
      renderEncoder .setDepthStencilState   (renderer .browser .depthStencilState [false])
      renderEncoder .setRenderPipelineState (renderer .browser .renderPipelineState [transparency > 0 ? .GouraudTransparent : .GouraudOpaque]!)
      
      // Set uniforms.
      let uniforms = sphereContext .uniforms
      
      uniforms .pointee .projectionMatrix = sphere ? renderer .projectionMatrix .top : .identity
      uniforms .pointee .modelViewMatrix  = sphere ? modelViewMatrix : .identity
      uniforms .pointee .numTextures      = 0
      uniforms .pointee .fog .type        = x3d_NoFog
      uniforms .pointee .lighting         = false
      uniforms .pointee .colorMaterial    = true

      // Set buffers.
      renderEncoder .setVertexBuffer   (spherePrimitivesBuffer,        offset: 0, index: 0)
      renderEncoder .setVertexBuffer   (sphereContext .uniformsBuffer, offset: 0, index: 1)
      renderEncoder .setFragmentBuffer (sphereContext .uniformsBuffer, offset: 0, index: 1)
      renderEncoder .setVertexBuffer   (lightSources  .uniformsBuffer, offset: 0, index: 2)
      renderEncoder .setFragmentBuffer (lightSources  .uniformsBuffer, offset: 0, index: 2)

      // Set front face and cull back facing triangles.
      renderEncoder .setFrontFacing (.counterClockwise)
      renderEncoder .setCullMode (.back)
      
      // Draw triangles.
      renderEncoder .drawPrimitives (type: .triangle, vertexStart: 0, vertexCount: spherePrimitives .count)
   }
   
   private final func renderCube (_ renderer : Renderer,
                                  _ renderEncoder : MTLRenderCommandEncoder,
                                  _ modelViewMatrix : Matrix4f)
   {
      // Set render pipeline states.
      renderEncoder .setDepthStencilState (renderer .browser .depthStencilState [false])

      // Set uniform light buffers.
      renderEncoder .setVertexBuffer   (lightSources .uniformsBuffer, offset: 0, index: 2)
      renderEncoder .setFragmentBuffer (lightSources .uniformsBuffer, offset: 0, index: 2)

      // Set front face and cull back facing triangles.
      renderEncoder .setFrontFacing (.counterClockwise)
      renderEncoder .setCullMode (.back)
      
      // Set vertex buffer.
      renderEncoder .setVertexBuffer (cubePrimitivesBuffer, offset: 0, index: 0)

      for i in 0 ..< 6
      {
         guard let textureNode = textureNodes [i] else { continue }
         guard textureNode .checkTextureLoadState == .COMPLETE_STATE else { continue }
         
         // Set render pipeline states.
         renderEncoder .setRenderPipelineState (renderer .browser .renderPipelineState [textureNode .isTransparent ? .GouraudTransparent : .GouraudOpaque]!)

         // Set fragment texture.
         textureNode .setFragmentTexture (renderEncoder)
         
         // Set uniforms.
         let cubeContext = cubeContexts [i]
         let uniforms    = cubeContext .uniforms
         
         uniforms .pointee .projectionMatrix = renderer .projectionMatrix .top
         uniforms .pointee .modelViewMatrix  = modelViewMatrix
         uniforms .pointee .textureMatrices  = (.identity, .identity)
         uniforms .pointee .numTextures      = Int32 (textureNode .numTextures)
         uniforms .pointee .fog .type        = x3d_NoFog
         uniforms .pointee .lighting         = false
         uniforms .pointee .colorMaterial    = false

         // Set uniform buffers.
         renderEncoder .setVertexBuffer   (cubeContext .uniformsBuffer, offset: 0, index: 1)
         renderEncoder .setFragmentBuffer (cubeContext .uniformsBuffer, offset: 0, index: 1)
         
         // Draw triangles.
         renderEncoder .drawPrimitives (type: .triangle, vertexStart: i * 6, vertexCount: 6)
      }
   }
}
