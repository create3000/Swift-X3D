//
//  Collision.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class Collision :
   X3DGroupingNode,
   X3DSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Collision" }
   public final override class var component      : String { "Navigation" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool public final var enabled     : Bool = true
   @SFTime public final var collideTime : TimeInterval = 0
   @SFBool public final var isActive    : Bool = false
   @SFNode public final var proxy       : X3DNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initSensorNode ()

      types .append (.Collision)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "enabled",        $enabled)
      addField (.outputOnly,     "isActive",       $isActive)
      addField (.outputOnly,     "collideTime",    $collideTime)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.initializeOnly, "proxy",          $proxy)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
      
      if executionContext .specificationVersion == "2.0"
      {
         addFieldAlias (alias: "collide", name: "enabled")
      }
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Collision
   {
      return Collision (with: executionContext)
   }
}
