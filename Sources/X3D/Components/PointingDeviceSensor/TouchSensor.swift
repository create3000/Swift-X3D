//
//  TouchSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TouchSensor :
   X3DTouchSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TouchSensor" }
   internal final override class var component      : String { "PointingDeviceSensor" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFVec2f public final var hitTexCoord_changed : Vector2f = .zero
   @SFVec3f public final var hitNormal_changed   : Vector3f = .zero
   @SFVec3f public final var hitPoint_changed    : Vector3f = .zero

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TouchSensor)

      addField (.inputOutput, "metadata",            $metadata)
      addField (.inputOutput, "enabled",             $enabled)
      addField (.inputOutput, "description",         $description)
      addField (.outputOnly,  "hitTexCoord_changed", $hitTexCoord_changed)
      addField (.outputOnly,  "hitNormal_changed",   $hitNormal_changed)
      addField (.outputOnly,  "hitPoint_changed",    $hitPoint_changed)
      addField (.outputOnly,  "isOver",              $isOver)
      addField (.outputOnly,  "isActive",            $isActive)
      addField (.outputOnly,  "touchTime",           $touchTime)

      $hitPoint_changed .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TouchSensor
   {
      return TouchSensor (with: executionContext)
   }
}
