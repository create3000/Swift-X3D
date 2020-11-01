//
//  ScalarChaser.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ScalarChaser :
   X3DChaserNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ScalarChaser" }
   public final override class var component      : String { "Followers" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFFloat public final var set_value          : Float = 0
   @SFFloat public final var set_destination    : Float = 0
   @SFFloat public final var initialValue       : Float = 0
   @SFFloat public final var initialDestination : Float = 0
   @SFFloat public final var value_changed      : Float = 0

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ScalarChaser)

      addField (.inputOutput,    "metadata",           $metadata)
      addField (.inputOnly,      "set_value",          $set_value)
      addField (.inputOnly,      "set_destination",    $set_destination)
      addField (.initializeOnly, "initialValue",       $initialValue)
      addField (.initializeOnly, "initialDestination", $initialDestination)
      addField (.initializeOnly, "duration",           $duration)
      addField (.outputOnly,     "isActive",           $isActive)
      addField (.outputOnly,     "value_changed",      $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ScalarChaser
   {
      return ScalarChaser (with: executionContext)
   }
}
