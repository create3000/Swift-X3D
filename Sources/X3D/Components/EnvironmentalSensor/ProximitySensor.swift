//
//  ProximitySensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ProximitySensor :
   X3DEnvironmentalSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ProximitySensor" }
   public final override class var component      : String { "EnvironmentalSensor" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFVec3f    public final var centerOfRotation_changed : Vector3f = .zero
   @SFRotation public final var orientation_changed      : Rotation4f = .identity
   @SFVec3f    public final var position_changed         : Vector3f = .zero

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ProximitySensor)

      addField (.inputOutput, "metadata",                 $metadata)
      addField (.inputOutput, "enabled",                  $enabled)
      addField (.inputOutput, "size",                     $size)
      addField (.inputOutput, "center",                   $center)
      addField (.outputOnly,  "enterTime",                $enterTime)
      addField (.outputOnly,  "exitTime",                 $exitTime)
      addField (.outputOnly,  "isActive",                 $isActive)
      addField (.outputOnly,  "position_changed",         $position_changed)
      addField (.outputOnly,  "orientation_changed",      $orientation_changed)
      addField (.outputOnly,  "centerOfRotation_changed", $centerOfRotation_changed)

      $centerOfRotation_changed .unit = .length
      $position_changed         .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ProximitySensor
   {
      return ProximitySensor (with: executionContext)
   }
}
