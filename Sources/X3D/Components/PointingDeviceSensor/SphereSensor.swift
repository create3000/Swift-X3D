//
//  SphereSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class SphereSensor :
   X3DDragSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "SphereSensor" }
   public final override class var component      : String { "PointingDeviceSensor" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFRotation public final var offset           : Rotation4f = Rotation4f (0, 1, 0, 0)
   @SFRotation public final var rotation_changed : Rotation4f = Rotation4f .identity

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.SphereSensor)

      addField (.inputOutput, "metadata",           $metadata)
      addField (.inputOutput, "enabled",            $enabled)
      addField (.inputOutput, "description",        $description)
      addField (.inputOutput, "autoOffset",         $autoOffset)
      addField (.inputOutput, "offset",             $offset)
      addField (.outputOnly,  "trackPoint_changed", $trackPoint_changed)
      addField (.outputOnly,  "rotation_changed",   $rotation_changed)
      addField (.outputOnly,  "isOver",             $isOver)
      addField (.outputOnly,  "isActive",           $isActive)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SphereSensor
   {
      return SphereSensor (with: executionContext)
   }
}
