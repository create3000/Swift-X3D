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
   
   public final override class var typeName       : String { "PickableGroup" }
   public final override class var component      : String { "Picking" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }
   
   // Fields
   
   @SFBool   public final var pickable   : Bool = true
   @MFString public final var objectType : MFString .Value = ["ALL"]

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
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
