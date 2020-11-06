//
//  TransformSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TransformSensor :
   X3DEnvironmentalSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "TransformSensor" }
   public final override class var component      : String { "EnvironmentalSensor" }
   public final override class var componentLevel : Int32 { 3 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFNode     public final var targetObject        : X3DNode?
   @SFVec3f    public final var position_changed    : Vector3f = .zero
   @SFRotation public final var orientation_changed : Rotation4f = .identity

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TransformSensor)

      addField (.inputOutput, "metadata",            $metadata)
      addField (.inputOutput, "enabled",             $enabled)
      addField (.inputOutput, "size",                $size)
      addField (.inputOutput, "center",              $center)
      addField (.inputOutput, "targetObject",        $targetObject)
      addField (.outputOnly,  "enterTime",           $enterTime)
      addField (.outputOnly,  "exitTime",            $exitTime)
      addField (.outputOnly,  "isActive",            $isActive)
      addField (.outputOnly,  "position_changed",    $position_changed)
      addField (.outputOnly,  "orientation_changed", $orientation_changed)

      $position_changed .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TransformSensor
   {
      return TransformSensor (with: executionContext)
   }
}
