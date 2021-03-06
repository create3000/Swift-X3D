//
//  Polyline2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public final class Polyline2D :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Polyline2D" }
   internal final override class var component      : String { "Geometry2D" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "geometry" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFVec2f public final var lineSegments : [Vector2f]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Polyline2D)

      addField (.inputOutput, "metadata",     $metadata)
      addField (.inputOutput, "lineSegments", $lineSegments)

      $lineSegments .unit = .length
      
      geometryType  = 1
      primitiveType = .lineStrip
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Polyline2D
   {
      return Polyline2D (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      rebuild ()
   }

   // Build
   
   internal final override func build ()
   {
      guard lineSegments .count > 1 else { return }
      
      for vertex in lineSegments
      {
         addPrimitive (point: Vector3f (vertex .x, vertex .y, 0))
      }
   }
   
   // Rendering
   
   internal final override func render (_ context : RenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      renderLines (context, renderEncoder)
   }
}
