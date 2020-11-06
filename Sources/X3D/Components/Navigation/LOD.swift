//
//  LOD.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class LOD :
   X3DGroupingNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "LOD" }
   public final override class var component      : String { "Navigation" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool  public final var forceTransitions : Bool = false
   @SFVec3f public final var center           : Vector3f = .zero
   @MFFloat public final var range            : MFFloat .Value
   @SFInt32 public final var level_changed    : Int32 = -1

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.LOD)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.initializeOnly, "forceTransitions", $forceTransitions)
      addField (.initializeOnly, "center",           $center)
      addField (.initializeOnly, "range",            $range)
      addField (.outputOnly,     "level_changed",    $level_changed)
      addField (.initializeOnly, "bboxSize",         $bboxSize)
      addField (.initializeOnly, "bboxCenter",       $bboxCenter)
      addField (.inputOnly,      "addChildren",      $addChildren)
      addField (.inputOnly,      "removeChildren",   $removeChildren)
      addField (.inputOutput,    "children",         $children)
      
      if executionContext .specificationVersion == "2.0"
      {
         addFieldAlias (alias: "level", name: "children")
      }

      $center .unit = .length
      $range  .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> LOD
   {
      return LOD (with: executionContext)
   }
}
