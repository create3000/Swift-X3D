//
//  Group.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Group :
   X3DGroupingNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Group" }
   public final override class var component      : String { "Grouping" }
   public final override class var componentLevel : Int32 { 3 }
   public final override class var containerField : String { "children" }

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Group)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Group
   {
      return Group (with: executionContext)
   }
}
