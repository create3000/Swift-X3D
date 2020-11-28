//
//  PickableGroup.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PickableGroup :
   X3DGroupingNode,
   X3DPickableObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "PickableGroup" }
   internal final override class var component      : String { "Picking" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   
   // Fields
   
   @SFBool   public final var pickable   : Bool = true
   @MFString public final var objectType : [String] = ["ALL"]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initPickableObject ()

      types .append (.PickableGroup)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "pickable",       $pickable)
      addField (.inputOutput,    "objectType",     $objectType)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PickableGroup
   {
      return PickableGroup (with: executionContext)
   }
}
