//
//  Billboard.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Billboard :
   X3DGroupingNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Billboard" }
   public final override class var component      : String { "Navigation" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFVec3f public final var axisOfRotation : Vector3f = Vector3f (0, 1, 0)

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Billboard)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "axisOfRotation", $axisOfRotation)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Billboard
   {
      return Billboard (with: executionContext)
   }
}
