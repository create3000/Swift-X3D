//
//  X3DGeometryNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal
import simd

enum X3DGeometryType :
   Int
{
   case points = 1
   case lines  = 2
}

public class X3DGeometryNode :
   X3DNode
{
   // Properties
   
   @SFBool internal final var isTransparent : Bool = false

   public private(set) final var bbox = Box3f ()
   
   internal final var geometryType       : Int = 3
   internal final var isCounterClockwise : Bool = true
   internal final var isSolid            : Bool = false
   internal final var hasFogCoord        : Bool = false
   internal final var hasColor           : Bool = false
   internal final var hasTexCoord        : Bool = false

   // Primitive Handling
   
   internal final var primitiveType : MTLPrimitiveType = .triangle

   /// Returns number of vertices for one primitive.
   private final var primitiveCount : Int
   {
      switch primitiveType
      {
         case .point:
            return 1
         case .lineStrip:
            return 1
         case .line:
            return 2
         case .triangleStrip:
            return 1
         case .triangle:
            return 3
         default:
            return 1
      }
   }
   
   internal typealias Primitives = [x3d_VertexIn]

   private final var primitives       : Primitives = Primitives ()
   private final var primitivesBuffer : MTLBuffer?

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DGeometryNode)
      
      addChildObjects ($isTransparent)
   }

   internal override func initialize ()
   {
      super .initialize ()
      
      addInterest (X3DGeometryNode .rebuild, self)
   }
   
   // Transparent handling
   
   internal final func setTransparent (_ value : Bool)
   {
      guard value != isTransparent else { return }
      
      isTransparent = value
   }

   // Build
   
   internal final func requestRebuild ()
   {
      rebuild ()
   }
   
   /// Updates geometry.
   internal final func rebuild ()
   {
      primitives .removeAll (keepingCapacity: true)
      
      build ()
      
      bbox = makeBBox ()
      
      guard !primitives .isEmpty else { return }

      // Trim vertices to multiple of primitive count.
      primitives .removeSubrange ((primitives .count - primitives .count % primitiveCount)...)
      
      if (geometryType == 2 || geometryType == 3) && !hasTexCoord
      {
         generateTexCoords (&primitives)
      }
      
      primitivesBuffer = browser! .device! .makeBuffer (bytes: primitives, length: primitives .count * MemoryLayout <x3d_VertexIn> .stride, options: [ ])!
   }

   /// Override to add vertices.
   internal func build () { }

   /// Add a vertex to the list of vertices.
   internal final func addPrimitive (fogDepth : Float = 0,
                                     color: Vector4f = Vector4f .one,
                                     texCoords: [Vector4f] = [ ],
                                     normal: Vector3f = Vector3f .zAxis,
                                     point: Vector3f)
   {
      var multiTexCoords = (Vector4f .zero, Vector4f .zero)
      
      switch texCoords .count
      {
         case 0:
            break
         case 1:
            multiTexCoords = (texCoords [0], texCoords [0])
         default:
            multiTexCoords = (texCoords [0], texCoords [1])
      }
      
      primitives .append (x3d_VertexIn (
         fogDepth: fogDepth,
         color: color,
         texCoords: multiTexCoords,
         normal: normal,
         point: Vector4f (point, 1)
      ))
   }

   /// Override to make a bbox.
   internal func makeBBox () -> Box3f
   {
      guard !primitives .isEmpty else { return Box3f () }
      
      let (min, max) = primitives .reduce ((min: Vector4f (repeating:  Float .infinity),
                                            max: Vector4f (repeating: -Float .infinity)))
      {
         (min: simd_min ($0 .min, $1 .point),
          max: simd_max ($0 .max, $1 .point))
      }
      
      return Box3f (min: Vector3f (min .x, min .y, min .z),
                    max: Vector3f (max .x, max .y, max .z))
   }
   
   /// Override to generate texture coordinates.
   internal func generateTexCoords (_ primitives : inout Primitives)
   {
      let p = texCoordParams

      for i in 0 ..< primitives .count
      {
         let point = primitives [i] .point
         
         let t = Vector4f ((point [p .Sindex] - p .min [p .Sindex]) / p .Ssize,
                           (point [p .Tindex] - p .min [p .Tindex]) / p .Ssize,
                           0,
                           1)
         
         primitives [i] .texCoords = (t, t)
      }
   }
   
   ///  Determine the min extent of the bbox, the largest size of the bbox and the two largest indices.
   internal final var texCoordParams : (min : Vector3f, Ssize : Float, Sindex : Int, Tindex : Int)
   {
      // Thanks to H3D.

      let size = bbox .size
      let min  = bbox .center - size / 2

      let Xsize = size .x
      let Ysize = size .y
      let Zsize = size .z
      
      var Ssize  = Float (0)
      var Sindex = 0
      var Tindex = 0

      if (Xsize >= Ysize) && (Xsize >= Zsize)
      {
         // X size largest
         Ssize  = Xsize
         Sindex = 0

         if Ysize >= Zsize
         {
            Tindex = 1
         }
         else
         {
            Tindex = 2
         }
      }
      else if (Ysize >= Xsize) && (Ysize >= Zsize)
      {
         // Y size largest
         Ssize  = Ysize
         Sindex = 1

         if (Xsize >= Zsize)
         {
            Tindex = 0
         }
         else
         {
            Tindex = 2
         }
      }
      else
      {
         // Z is the largest
         Ssize  = Zsize
         Sindex = 2

         if Xsize >= Ysize
         {
            Tindex = 0
         }
         else
         {
            Tindex = 1
         }
      }
      
      return (min, Ssize, Sindex, Tindex)
   }
   
   // Normal generation
   
   internal typealias Normals     = [Vector3f]
   internal typealias NormalIndex = [Int : [Int]]

   /// Generate smooth normals from `normalIndex` and `faceNormal` with `creaseAngle` as limit.
   internal final func generateNormals (normalIndex : NormalIndex, faceNormals : Normals, creaseAngle : Float) -> Normals
   {
      if creaseAngle == 0
      {
         return faceNormals
      }

      let cosCreaseAngle = cos (clamp (creaseAngle, min: 0, max: Float .pi))
      var normals        = Normals (repeating: Vector3f .zero, count: faceNormals .count)
      
      for (_, vertex) in normalIndex
      {
         for p in vertex
         {
            let P = faceNormals [p]
            var n = Vector3f .zero

            for q in vertex
            {
               let Q = faceNormals [q]

               if dot (Q, P) >= cosCreaseAngle
               {
                  n += Q
               }
            }

            normals [p] = normalize (n)
         }
      }

      return normals
   }

   // Rendering
   
   internal func traverse (_ type : X3DTraverseType, _ renderer : X3DRenderer) { }
   
   /// Renders geometry to surface with selected shader.
   internal func render (_ context : X3DRenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      guard !primitives .isEmpty else { return }
      
      // Get properties.
      let browser  = context .browser!
      let renderer = context .renderer
      let uniforms = context .uniforms
      
      // Select shader.
      context .shaderNode? .enable (renderEncoder, blending: context .isTransparent)
      
      // Set uniforms.
      context .fogObject .setUniforms (uniforms)
      
      // Set local lights and clip planes.
      
      let lightSources = renderer .lightSources
      
      for index in 0 ..< context .localLights .count
      {
         context .localLights [index] .setUniforms (lightSources, renderer .globalLights .count + index)
      }
      
      uniforms .pointee .numLights     = max (Int32 (renderer .globalLights .count + context .localLights .count), x3d_MaxLights)
      uniforms .pointee .fog .fogCoord = hasFogCoord
      uniforms .pointee .colorMaterial = hasColor

      // Set uniforms and vertex buffer.
      renderEncoder .setVertexBuffer   (primitivesBuffer,        offset: 0, index: 0)
      renderEncoder .setVertexBuffer   (context .uniformsBuffer, offset: 0, index: 1)
      renderEncoder .setFragmentBuffer (context .uniformsBuffer, offset: 0, index: 1)

      // Set front face depending on scale.
      let positiveScale = uniforms .pointee .modelViewMatrix .submatrix .determinant > 0
      
      renderEncoder .setFrontFacing (positiveScale
                                     ? (isCounterClockwise ? .counterClockwise : .clockwise)
                                     : (isCounterClockwise ? .clockwise : .counterClockwise))
      
      // Draw transparent or opaque triangles.
      if context .isTransparent
      {
         if !isSolid
         {
            // Draw back facing triangles.
            renderEncoder .setCullMode (.front)
            renderEncoder .drawPrimitives (type: primitiveType, vertexStart: 0, vertexCount: primitives .count)
         }

         // Draw front facing triangles.
         renderEncoder .setCullMode (.back)
         renderEncoder .drawPrimitives (type: primitiveType, vertexStart: 0, vertexCount: primitives .count)
      }
      else
      {
         // Cull back facing triangles if is solid.
         renderEncoder .setCullMode (isSolid ? .back : .none)
         
         // Draw triangles.
         renderEncoder .drawPrimitives (type: primitiveType, vertexStart: 0, vertexCount: primitives .count)
      }

      // Revert shader.
      if context .shaderNode != nil
      {
         renderEncoder .setRenderPipelineState (browser .defaultRenderPipelineState [context .isTransparent]!)
      }

      // Count primitives.
      renderer .primitives .triangles += primitives .count / primitiveCount
   }
}

// Line geometry handling

extension X3DGeometryNode
{
   /// Renders geometry to surface with selected shader.
   internal func renderLines (_ context : X3DRenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      guard !primitives .isEmpty else { return }
      
      // Get properties.
      let browser  = context .browser!
      let renderer = context .renderer
      let uniforms = context .uniforms

      // Select shader.
      if let shaderNode = context .shaderNode
      {
         shaderNode .enable (renderEncoder, blending: context .isTransparent)
      }
      else
      {
         renderEncoder .setRenderPipelineState (browser .renderPipelineState [context .isTransparent ? .LineTransparent : .LineOpaque]!)
      }
      
      // Set uniforms.
      context .fogObject .setUniforms (uniforms)

      uniforms .pointee .fog .fogCoord = hasFogCoord
      uniforms .pointee .colorMaterial = hasColor

      // Set uniforms and vertex buffer.
      renderEncoder .setVertexBuffer   (primitivesBuffer,        offset: 0, index: 0)
      renderEncoder .setVertexBuffer   (context .uniformsBuffer, offset: 0, index: 1)
      renderEncoder .setFragmentBuffer (context .uniformsBuffer, offset: 0, index: 1)

      // Draw triangles.
      renderEncoder .drawPrimitives (type: primitiveType, vertexStart: 0, vertexCount: primitives .count)
      
      // Revert shader.
      renderEncoder .setRenderPipelineState (browser .defaultRenderPipelineState [context .isTransparent]!)

      // Count primitives.
      renderer .primitives .lines += primitives .count / primitiveCount

      if primitiveType == .lineStrip
      {
         renderer .primitives .lines -= 1
      }
   }
}

// Point geometry handling

extension X3DGeometryNode
{
   /// Renders geometry to surface with selected shader.
   internal func renderPoints (_ context : X3DRenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      guard !primitives .isEmpty else { return }
      
      // Get properties.
      let browser  = context .browser!
      let renderer = context .renderer
      let uniforms = context .uniforms

      // Select shader.
      if let shaderNode = context .shaderNode
      {
         shaderNode .enable (renderEncoder, blending: context .isTransparent)
      }
      else
      {
         renderEncoder .setRenderPipelineState (browser .renderPipelineState [context .isTransparent ? .PointTransparent : .PointOpaque]!)
      }

      // Set uniforms.
      context .fogObject .setUniforms (uniforms)
      
      uniforms .pointee .fog .fogCoord = hasFogCoord
      uniforms .pointee .colorMaterial = hasColor

      // Set uniforms and vertex buffer.
      renderEncoder .setVertexBuffer   (primitivesBuffer,        offset: 0, index: 0)
      renderEncoder .setVertexBuffer   (context .uniformsBuffer, offset: 0, index: 1)
      renderEncoder .setFragmentBuffer (context .uniformsBuffer, offset: 0, index: 1)

      // Draw triangles.
      renderEncoder .drawPrimitives (type: primitiveType, vertexStart: 0, vertexCount: primitives .count)
      
      // Revert shader.
      renderEncoder .setRenderPipelineState (browser .defaultRenderPipelineState [context .isTransparent]!)

      // Count primitives.
      renderer .primitives .points += primitives .count
   }
}
