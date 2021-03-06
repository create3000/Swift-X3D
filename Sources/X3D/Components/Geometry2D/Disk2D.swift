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
   
   internal final override class var typeName       : String { "Disk2D" }
   internal final override class var component      : String { "Geometry2D" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "geometry" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFFloat public final var innerRadius : Float = 0
   @SFFloat public final var outerRadius : Float = 1
   @SFBool  public final var solid       : Bool = false

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
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
         guard let browser = self .browser else { return }
         
         browser .disk2DOptions .addInterest ("requestRebuild", { $0 .requestRebuild () }, self)
         
         self .rebuild ()
      }
   }
   
   // Build

   internal final override func makeBBox () -> Box3f
   {
      let outerRadius = max (abs (self .innerRadius), abs (self .outerRadius))
      
      return Box3f (min: Vector3f (-outerRadius, -outerRadius, 0),
                    max: Vector3f ( outerRadius,  outerRadius, 0))
   }

   internal final override func build ()
   {
      guard let browser = browser else { return }
      
      let innerRadius = min (abs (self .innerRadius), abs (self .outerRadius))
      let outerRadius = max (abs (self .innerRadius), abs (self .outerRadius))

      if innerRadius == outerRadius
      {
         // Point
         
         if outerRadius == 0
         {
            //geometryType  = 0
            //primitiveType = .point
            
            //addPrimitive (point: Vector3f (0, 0, 0))
            return
         }

         // Circle
         
         geometryType  = 1
         primitiveType = .lineStrip
         
         if outerRadius == 1
         {
            for vertex in browser .disk2DOptions .circlePrimitives
            {
               addPrimitive (point: vertex)
            }
         }
         else
         {
            for vertex in browser .disk2DOptions .circlePrimitives
            {
               addPrimitive (point: vertex * outerRadius)
            }
         }
    
         return
      }

      // Disk
      
      if innerRadius == 0
      {
         geometryType  = 2
         primitiveType = .triangle
         isSolid       = solid
         hasTexCoord   = true

         if outerRadius == 1
         {
            for vertex in browser .disk2DOptions .diskPrimitives
            {
               addPrimitive (texCoords: [vertex .texCoord],
                             normal: .zAxis,
                             point: vertex .point)
            }
         }
         else
         {
            for vertex in browser .disk2DOptions .diskPrimitives
            {
               addPrimitive (texCoords: [vertex .texCoord],
                             normal: .zAxis,
                             point: vertex .point * outerRadius)
            }
         }

         return
      }
 
      // Disk with hole
      
      geometryType  = 2
      primitiveType = .triangle
      isSolid       = solid
      hasTexCoord   = true

      let scale            = innerRadius / outerRadius
      let offset           = (1 - scale) / 2
      let primitives       = browser .disk2DOptions .diskPrimitives

      for i in stride (from: 0, to: primitives .count, by: 3)
      {
         let p2 = primitives [i + 1]
         let p4 = primitives [i + 2]

         addPrimitive (texCoords: [Vector4f (p2 .texCoord .x * scale + offset, p2 .texCoord .y * scale + offset, 0, 1)],
                       normal: .zAxis,
                       point: Vector3f (p2 .point * innerRadius))
         
         addPrimitive (texCoords: [p2 .texCoord],
                       normal: .zAxis,
                       point: Vector3f (p2 .point * outerRadius))
         
         addPrimitive (texCoords: [p4 .texCoord],
                       normal: .zAxis,
                       point: Vector3f (p4 .point * outerRadius))

         
         addPrimitive (texCoords: [Vector4f (p2 .texCoord .x * scale + offset, p2 .texCoord .y * scale + offset, 0, 1)],
                       normal: .zAxis,
                       point: Vector3f (p2 .point * innerRadius))
         
         addPrimitive (texCoords: [p4 .texCoord],
                       normal: .zAxis,
                       point: Vector3f (p4 .point * outerRadius))
         
         addPrimitive (texCoords: [Vector4f (p4 .texCoord .x * scale + offset, p4 .texCoord .y * scale + offset, 0, 1)],
                       normal: .zAxis,
                       point: Vector3f (p4 .point * innerRadius))
      }
   }
   
   // Rendering
   
   internal final override func render (_ context : RenderContext, _ renderEncoder : MTLRenderCommandEncoder)
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
