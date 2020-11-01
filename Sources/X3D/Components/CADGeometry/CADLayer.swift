//
//  CADLayer.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CADLayer :
   X3DGroupingNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "CADLayer" }
   public final override class var component      : String { "CADGeometry" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFString public final var name : String = ""

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.CADLayer)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "name",           $name)
      addField (.inputOutput,    "visible",        $visible)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CADLayer
   {
      return CADLayer (with: executionContext)
   }
}
