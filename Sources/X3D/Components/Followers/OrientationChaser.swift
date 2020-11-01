//
//  OrientationChaser.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class OrientationChaser :
   X3DChaserNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "OrientationChaser" }
   public final override class var component      : String { "Followers" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFRotation public final var set_value          : Rotation4f = Rotation4f .identity
   @SFRotation public final var set_destination    : Rotation4f = Rotation4f .identity
   @SFRotation public final var initialValue       : Rotation4f = Rotation4f (0, 1, 0, 0)
   @SFRotation public final var initialDestination : Rotation4f = Rotation4f (0, 1, 0, 0)
   @SFRotation public final var value_changed      : Rotation4f = Rotation4f .identity

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.OrientationChaser)

      addField (.inputOutput,    "metadata",           $metadata)
      addField (.inputOnly,      "set_value",          $set_value)
      addField (.inputOnly,      "set_destination",    $set_destination)
      addField (.initializeOnly, "initialValue",       $initialValue)
      addField (.initializeOnly, "initialDestination", $initialDestination)
      addField (.initializeOnly, "duration",           $duration)
      addField (.outputOnly,     "isActive",           $isActive)
      addField (.outputOnly,     "value_changed",      $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> OrientationChaser
   {
      return OrientationChaser (with: executionContext)
   }
}
