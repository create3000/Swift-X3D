//
//  LinePickSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class LinePickSensor :
   X3DPickSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "LinePickSensor" }
   internal final override class var component      : String { "Picking" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @MFVec3f public final var pickedTextureCoordinate : [Vector3f]
   @MFVec3f public final var pickedNormal            : [Vector3f]
   @MFVec3f public final var pickedPoint             : [Vector3f]

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.LinePickSensor)

      addField (.inputOutput,    "metadata",                $metadata)
      addField (.inputOutput,    "enabled",                 $enabled)
      addField (.inputOutput,    "objectType",              $objectType)
      addField (.inputOutput,    "matchCriterion",          $matchCriterion)
      addField (.initializeOnly, "intersectionType",        $intersectionType)
      addField (.initializeOnly, "sortOrder",               $sortOrder)
      addField (.inputOutput,    "pickingGeometry",         $pickingGeometry)
      addField (.inputOutput,    "pickTarget",              $pickTarget)
      addField (.outputOnly,     "isActive",                $isActive)
      addField (.outputOnly,     "pickedTextureCoordinate", $pickedTextureCoordinate)
      addField (.outputOnly,     "pickedNormal",            $pickedNormal)
      addField (.outputOnly,     "pickedPoint",             $pickedPoint)
      addField (.outputOnly,     "pickedGeometry",          $pickedGeometry)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> LinePickSensor
   {
      return LinePickSensor (with: executionContext)
   }
}
