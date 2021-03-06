//
//  ContourPolyline2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ContourPolyline2D :
   X3DNurbsControlCurveNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ContourPolyline2D" }
   internal final override class var component      : String { "NURBS" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ContourPolyline2D)

      addField (.inputOutput, "metadata",     $metadata)
      addField (.inputOutput, "controlPoint", $controlPoint)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ContourPolyline2D
   {
      return ContourPolyline2D (with: executionContext)
   }
}
