//
//  PositionDamper2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PositionDamper2D :
   X3DDamperNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "PositionDamper2D" }
   public final override class var component      : String { "Followers" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFVec2f public final var set_value          : Vector2f = .zero
   @SFVec2f public final var set_destination    : Vector2f = .zero
   @SFVec2f public final var initialValue       : Vector2f = .zero
   @SFVec2f public final var initialDestination : Vector2f = .zero
   @SFVec2f public final var value_changed      : Vector2f = .zero

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PositionDamper2D)

      addField (.inputOutput,    "metadata",           $metadata)
      addField (.inputOnly,      "set_value",          $set_value)
      addField (.inputOnly,      "set_destination",    $set_destination)
      addField (.initializeOnly, "initialValue",       $initialValue)
      addField (.initializeOnly, "initialDestination", $initialDestination)
      addField (.initializeOnly, "order",              $order)
      addField (.inputOutput,    "tau",                $tau)
      addField (.inputOutput,    "tolerance",          $tolerance)
      addField (.outputOnly,     "isActive",           $isActive)
      addField (.outputOnly,     "value_changed",      $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PositionDamper2D
   {
      return PositionDamper2D (with: executionContext)
   }
}
