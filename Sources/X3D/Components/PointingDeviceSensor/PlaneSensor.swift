//
//  PlaneSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PlaneSensor :
   X3DDragSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "PlaneSensor" }
   public final override class var component      : String { "PointingDeviceSensor" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFRotation public final var axisRotation        : Rotation4f = Rotation4f .identity
   @SFVec3f    public final var offset              : Vector3f = Vector3f .zero
   @SFVec2f    public final var minPosition         : Vector2f = Vector2f .zero
   @SFVec2f    public final var maxPosition         : Vector2f = Vector2f (-1, -1)
   @SFVec3f    public final var translation_changed : Vector3f = Vector3f .zero

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PlaneSensor)

      addField (.inputOutput, "metadata",            $metadata)
      addField (.inputOutput, "enabled",             $enabled)
      addField (.inputOutput, "description",         $description)
      addField (.inputOutput, "axisRotation",        $axisRotation)
      addField (.inputOutput, "autoOffset",          $autoOffset)
      addField (.inputOutput, "offset",              $offset)
      addField (.inputOutput, "minPosition",         $minPosition)
      addField (.inputOutput, "maxPosition",         $maxPosition)
      addField (.outputOnly,  "trackPoint_changed",  $trackPoint_changed)
      addField (.outputOnly,  "translation_changed", $translation_changed)
      addField (.outputOnly,  "isOver",              $isOver)
      addField (.outputOnly,  "isActive",            $isActive)

      $offset              .unit = .length
      $minPosition         .unit = .length
      $maxPosition         .unit = .length
      $translation_changed .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PlaneSensor
   {
      return PlaneSensor (with: executionContext)
   }
}
