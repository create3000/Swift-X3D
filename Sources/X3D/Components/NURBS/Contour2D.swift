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
   
   public final override class var typeName       : String { "Contour2D" }
   public final override class var component      : String { "NURBS" }
   public final override class var componentLevel : Int32 { 4 }
   public final override class var containerField : String { "trimmingContour" }

   // Fields

   @MFNode public final var addChildren    : MFNode <X3DNode> .Value
   @MFNode public final var removeChildren : MFNode <X3DNode> .Value
   @MFNode public final var children       : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
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
