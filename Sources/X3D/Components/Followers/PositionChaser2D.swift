//
//  PositionChaser2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PositionChaser2D :
   X3DChaserNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "PositionChaser2D" }
   internal final override class var component      : String { "Followers" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFVec2f public final var set_value          : Vector2f = .zero
   @SFVec2f public final var set_destination    : Vector2f = .zero
   @SFVec2f public final var initialValue       : Vector2f = .zero
   @SFVec2f public final var initialDestination : Vector2f = .zero
   @SFVec2f public final var value_changed      : Vector2f = .zero

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PositionChaser2D)

      addField (.inputOutput,    "metadata",           $metadata)
      addField (.inputOnly,      "set_value",          $set_value)
      addField (.inputOnly,      "set_destination",    $set_destination)
      addField (.initializeOnly, "initialValue",       $initialValue)
      addField (.initializeOnly, "initialDestination", $initialDestination)
      addField (.initializeOnly, "duration",           $duration)
      addField (.outputOnly,     "isActive",           $isActive)
      addField (.outputOnly,     "value_changed",      $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PositionChaser2D
   {
      return PositionChaser2D (with: executionContext)
   }
}
