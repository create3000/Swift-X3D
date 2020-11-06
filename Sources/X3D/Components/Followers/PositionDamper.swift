//
//  PositionDamper.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PositionDamper :
   X3DDamperNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "PositionDamper" }
   public final override class var component      : String { "Followers" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFVec3f public final var set_value          : Vector3f = .zero
   @SFVec3f public final var set_destination    : Vector3f = .zero
   @SFVec3f public final var initialValue       : Vector3f = .zero
   @SFVec3f public final var initialDestination : Vector3f = .zero
   @SFVec3f public final var value_changed      : Vector3f = .zero

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PositionDamper)

      addField (.inputOutput,    "metadata",           $metadata)
      addField (.inputOnly,      "set_value",          $set_value)
      addField (.inputOnly,      "set_destination",    $set_destination)
      addField (.initializeOnly, "initialValue",       $initialValue)
      addField (.initializeOnly, "initialDestination", $initialDestination)
      addField (.initializeOnly, "order",              $order)
      addField (.inputOutput,    "tolerance",          $tolerance)
      addField (.inputOutput,    "tau",                $tau)
      addField (.outputOnly,     "value_changed",      $value_changed)
      addField (.outputOnly,     "isActive",           $isActive)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PositionDamper
   {
      return PositionDamper (with: executionContext)
   }
}
