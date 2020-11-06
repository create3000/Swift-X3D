//
//  Disk2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation
import Metal

public final class Disk2D :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Disk2D" }
   public final override class var component      : String { "Geometry2D" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "geometry" }

   // Fields

   @SFFloat public final var innerRadius : Float = 0
   @SFFloat public final var outerRadius : Float = 1
   @SFBool  public final var solid       : Bool = false

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Disk2D)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.initializeOnly, "innerRadius", $innerRadius)
      addField (.initializeOnly, "outerRadius", $outerRadius)
      addField (.initializeOnly, "solid",       $solid)

      $innerRadius .unit = .length
      $outerRadius .unit = .length
      
      geometryType = 2
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Disk2D
   {
      return Disk2D (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      DispatchQueue .main .async
      {
         self .browser! .disk2DOptions .addInterest (Disk2D .requestRebuild, self)
         
         self .rebuild ()
      }
   }
   
   // Build

   internal final override func makeBBox () -> Box3f
   {
      let radius = max (innerRadius, outerRadius)
      
      return Box3f (min: Vector3f (-radius, -radius, 0),
                    max: Vector3f ( radius,  radius, 0))
   }

   internal final override func build ()
   {
      if innerRadius == outerRadius
      {
         let radius = abs (outerRadius)
         
         // Point
         
         if radius == 0
         {
            //geometryType  = 0
            //primitiveType = .point
            
            //addPrimitive (point: Vector3f (0, 0, 0))
            return
         }

         // Circle
         
         geometryType  = 1
         primitiveType = .lineStrip
         
         if radius == 1
         {
            for vertex in browser! .disk2DOptions .circlePrimitives
            {
               addPrimitive (point: vertex)
            }
         }
         else
         {
            for vertex in browser! .disk2DOptions .circlePrimitives
            {
               addPrimitive (point: vertex * radius)
            }
         }
    
         return
      }

      // Disk
      
      if innerRadius == 0 || outerRadius == 0
      {
         geometryType  = 2
         primitiveType = .triangle
         isSolid       = solid
         hasTexCoord   = true

         let radius = abs (max (innerRadius, outerRadius))

         if radius == 1
         {
            for vertex in browser! .disk2DOptions .diskPrimitives
            {
               addPrimitive (texCoords: [vertex .texCoord],
                             normal: .zAxis,
                             point: vertex .point)
            }
         }
         else
         {
            for vertex in browser! .disk2DOptions .diskPrimitives
            {
               addPrimitive (texCoords: [vertex .texCoord],
                             normal: .zAxis,
                             point: vertex .point * radius)
            }
         }

         return
      }
 
      // Disk with hole
      
      geometryType  = 2
      primitiveType = .triangle
      isSolid       = solid
      hasTexCoord   = true

      let maxRadius        = abs (max (innerRadius, outerRadius))
      let minRadius        = abs (min (innerRadius, outerRadius))
      let scale            = minRadius / maxRadius
      let offset           = (1 - scale) / 2
      let primitives       = browser! .disk2DOptions .diskPrimitives

      for i in stride (from: 0, to: primitives .count, by: 3)
      {
         let p2 = primitives [i + 1]
         let p4 = primitives [i + 2]

         addPrimitive (texCoords: [Vector4f (p2 .texCoord .x * scale + offset, p2 .texCoord .y * scale + offset, 0, 1)],
                       normal: .zAxis,
                       point: Vector3f (p2 .point * minRadius))
         
         addPrimitive (texCoords: [p2 .texCoord],
                       normal: .zAxis,
                       point: Vector3f (p2 .point * maxRadius))
         
         addPrimitive (texCoords: [p4 .texCoord],
                       normal: .zAxis,
                       point: Vector3f (p4 .point * maxRadius))

         
         addPrimitive (texCoords: [Vector4f (p2 .texCoord .x * scale + offset, p2 .texCoord .y * scale + offset, 0, 1)],
                       normal: .zAxis,
                       point: Vector3f (p2 .point * minRadius))
         
         addPrimitive (texCoords: [p4 .texCoord],
                       normal: .zAxis,
                       point: Vector3f (p4 .point * maxRadius))
         
         addPrimitive (texCoords: [Vector4f (p4 .texCoord .x * scale + offset, p4 .texCoord .y * scale + offset, 0, 1)],
                       normal: .zAxis,
                       point: Vector3f (p4 .point * minRadius))
      }
   }
   
   // Rendering
   
   internal final override func render (_ context : X3DRenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      switch geometryType
      {
         case 0:
            renderPoints (context, renderEncoder)
         case 1:
            renderLines (context, renderEncoder)
         default:
            super .render (context, renderEncoder)
      }
   }
}
