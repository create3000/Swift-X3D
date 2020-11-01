//
//  VisibilitySensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class VisibilitySensor :
   X3DEnvironmentalSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "VisibilitySensor" }
   public final override class var component      : String { "EnvironmentalSensor" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.VisibilitySensor)

      addField (.inputOutput, "metadata",  $metadata)
      addField (.inputOutput, "enabled",   $enabled)
      addField (.inputOutput, "size",      $size)
      addField (.inputOutput, "center",    $center)
      addField (.outputOnly,  "enterTime", $enterTime)
      addField (.outputOnly,  "exitTime",  $exitTime)
      addField (.outputOnly,  "isActive",  $isActive)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> VisibilitySensor
   {
      return VisibilitySensor (with: executionContext)
   }
}
