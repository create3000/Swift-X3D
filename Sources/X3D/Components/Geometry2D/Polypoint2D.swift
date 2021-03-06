//
//  Polypoint2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public final class Polypoint2D :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Polypoint2D" }
   internal final override class var component      : String { "Geometry2D" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "geometry" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFVec2f public final var point : [Vector2f]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Polypoint2D)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "point",    $point)

      $point .unit = .length
      
      geometryType  = 0
      primitiveType = .point
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Polypoint2D
   {
      return Polypoint2D (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      rebuild ()
   }
   // Build
   
   internal final override func build ()
   {
      for point in point
      {
         addPrimitive (point: Vector3f (point .x, point .y, 0))
      }
   }
   
   // Rendering
   
   internal final override func render (_ context : RenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      renderPoints (context, renderEncoder)
   }
}
