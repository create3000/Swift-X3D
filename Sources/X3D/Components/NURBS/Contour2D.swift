//
//  Contour2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Contour2D :
   X3DNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Contour2D" }
   internal final override class var component      : String { "NURBS" }
   internal final override class var componentLevel : Int32 { 4 }
   internal final override class var containerField : String { "trimmingContour" }

   // Fields

   @MFNode public final var addChildren    : [X3DNode?]
   @MFNode public final var removeChildren : [X3DNode?]
   @MFNode public final var children       : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Contour2D)

      addField (.inputOutput, "metadata",       $metadata)
      addField (.inputOnly,   "addChildren",    $addChildren)
      addField (.inputOnly,   "removeChildren", $removeChildren)
      addField (.inputOutput, "children",       $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Contour2D
   {
      return Contour2D (with: executionContext)
   }
}
