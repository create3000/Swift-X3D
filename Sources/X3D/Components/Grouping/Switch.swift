//
//  Switch.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class Switch :
   X3DGroupingNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Switch" }
   public final override class var component      : String { "Grouping" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }
   
   // Fields
   
   @SFInt32 public final var whichChoice : Int32 = 0

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Switch)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "whichChoice",    $whichChoice)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
      
      if executionContext .specificationVersion == "2.0"
      {
         addFieldAlias (alias: "choice", name: "children")
      }
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Switch
   {
      return Switch (with: executionContext)
   }
}
