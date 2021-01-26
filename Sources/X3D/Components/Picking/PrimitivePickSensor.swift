//
//  PrimitivePickSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PrimitivePickSensor :
   X3DPickSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "PrimitivePickSensor" }
   internal final override class var component      : String { "Picking" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PrimitivePickSensor)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOutput,    "enabled",          $enabled)
      addField (.inputOutput,    "objectType",       $objectType)
      addField (.inputOutput,    "matchCriterion",   $matchCriterion)
      addField (.initializeOnly, "intersectionType", $intersectionType)
      addField (.initializeOnly, "sortOrder",        $sortOrder)
      addField (.inputOutput,    "pickingGeometry",  $pickingGeometry)
      addField (.inputOutput,    "pickTarget",       $pickTarget)
      addField (.outputOnly,     "isActive",         $isActive)
      addField (.outputOnly,     "pickedGeometry",   $pickedGeometry)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PrimitivePickSensor
   {
      return PrimitivePickSensor (with: executionContext)
   }
}
