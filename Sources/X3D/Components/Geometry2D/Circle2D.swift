//
//  Circle2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public final class Circle2D :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Circle2D" }
   internal final override class var component      : String { "Geometry2D" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "geometry" }

   // Fields

   @SFFloat public final var radius : Float = 1

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Circle2D)

      addField (.inputOutput,    "metadata", $metadata)
      addField (.initializeOnly, "radius",   $radius)

      $radius .unit = .length
      
      geometryType  = 1
      primitiveType = .lineStrip
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Circle2D
   {
      return Circle2D (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      DispatchQueue .main .async
      {
         guard let browser = self .browser else { return }
         
         browser .circle2DOptions .addInterest ("requestRebuild", Circle2D .requestRebuild, self)
         
         self .rebuild ()
      }
   }

   // Build
   
   internal final override func makeBBox () -> Box3f
   {
      return Box3f (min: Vector3f (-radius, -radius, 0),
                    max: Vector3f ( radius,  radius, 0))
   }
   
   internal final override func build ()
   {
      guard let browser = browser else { return }
      
      let radius = abs (self .radius)
      
      if radius == 1
      {
         for vertex in browser .circle2DOptions .primitives
         {
            addPrimitive (point: vertex)
         }
      }
      else
      {
         for vertex in browser .circle2DOptions .primitives
         {
            addPrimitive (point: vertex * radius)
         }
      }
   }
   
   // Rendering
   
   internal final override func render (_ context : RenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      renderLines (context, renderEncoder)
   }
}
