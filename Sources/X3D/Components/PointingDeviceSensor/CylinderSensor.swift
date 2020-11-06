//
//  CylinderSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CylinderSensor :
   X3DDragSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "CylinderSensor" }
   public final override class var component      : String { "PointingDeviceSensor" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFRotation public final var axisRotation     : Rotation4f = Rotation4f (0, 1, 0, 0)
   @SFFloat    public final var diskAngle        : Float = 0.261792
   @SFFloat    public final var minAngle         : Float = 0
   @SFFloat    public final var maxAngle         : Float = -1
   @SFFloat    public final var offset           : Float = 0
   @SFRotation public final var rotation_changed : Rotation4f = .identity

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.CylinderSensor)

      addField (.inputOutput, "metadata",           $metadata)
      addField (.inputOutput, "enabled",            $enabled)
      addField (.inputOutput, "description",        $description)
      addField (.inputOutput, "axisRotation",       $axisRotation)
      addField (.inputOutput, "diskAngle",          $diskAngle)
      addField (.inputOutput, "minAngle",           $minAngle)
      addField (.inputOutput, "maxAngle",           $maxAngle)
      addField (.inputOutput, "offset",             $offset)
      addField (.inputOutput, "autoOffset",         $autoOffset)
      addField (.outputOnly,  "trackPoint_changed", $trackPoint_changed)
      addField (.outputOnly,  "rotation_changed",   $rotation_changed)
      addField (.outputOnly,  "isOver",             $isOver)
      addField (.outputOnly,  "isActive",           $isActive)

      $diskAngle .unit = .angle
      $minAngle  .unit = .angle
      $maxAngle  .unit = .angle
      $offset    .unit = .angle
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CylinderSensor
   {
      return CylinderSensor (with: executionContext)
   }
}
