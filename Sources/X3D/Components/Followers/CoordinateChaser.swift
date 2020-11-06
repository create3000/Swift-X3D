//
//  CoordinateChaser.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CoordinateChaser :
   X3DChaserNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "CoordinateChaser" }
   public final override class var component      : String { "Followers" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @MFVec3f public final var set_value          : MFVec3f .Value
   @MFVec3f public final var set_destination    : MFVec3f .Value
   @MFVec3f public final var initialValue       : MFVec3f .Value = [Vector3f ()]
   @MFVec3f public final var initialDestination : MFVec3f .Value = [Vector3f ()]
   @MFVec3f public final var value_changed      : MFVec3f .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.CoordinateChaser)

      addField (.inputOutput,    "metadata",           $metadata)
      addField (.inputOnly,      "set_value",          $set_value)
      addField (.inputOnly,      "set_destination",    $set_destination)
      addField (.initializeOnly, "initialValue",       $initialValue)
      addField (.initializeOnly, "initialDestination", $initialDestination)
      addField (.initializeOnly, "duration",           $duration)
      addField (.outputOnly,     "isActive",           $isActive)
      addField (.outputOnly,     "value_changed",      $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CoordinateChaser
   {
      return CoordinateChaser (with: executionContext)
   }
}
