//
//  LayoutGroup.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class LayoutGroup :
   X3DGroupingNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "LayoutGroup" }
   internal final override class var component      : String { "Layout" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFNode public final var viewport : X3DNode?
   @SFNode public final var layout   : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.LayoutGroup)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "layout",         $layout)
      addField (.inputOutput,    "viewport",       $viewport)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> LayoutGroup
   {
      return LayoutGroup (with: executionContext)
   }
}
