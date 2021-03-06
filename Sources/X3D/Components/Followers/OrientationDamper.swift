//
//  OrientationDamper.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class OrientationDamper :
   X3DDamperNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "OrientationDamper" }
   internal final override class var component      : String { "Followers" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFRotation public final var set_value          : Rotation4f = .identity
   @SFRotation public final var set_destination    : Rotation4f = .identity
   @SFRotation public final var initialValue       : Rotation4f = .identity
   @SFRotation public final var initialDestination : Rotation4f = .identity
   @SFRotation public final var value_changed      : Rotation4f = .identity

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.OrientationDamper)

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
      
      $set_value          .unit = .angle
      $set_destination    .unit = .angle
      $initialValue       .unit = .angle
      $initialDestination .unit = .angle
      $value_changed      .unit = .angle
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> OrientationDamper
   {
      return OrientationDamper (with: executionContext)
   }
}
