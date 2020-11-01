//
//  GeoTouchSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GeoTouchSensor :
   X3DTouchSensorNode,
   X3DGeospatialObject,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "GeoTouchSensor" }
   public final override class var component      : String { "Geospatial" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @MFString public final var geoSystem           : MFString .Value = ["GD", "WE"]
   @SFNode   public final var geoOrigin           : X3DNode?
   @SFVec2f  public final var hitTexCoord_changed : Vector2f = Vector2f .zero
   @SFVec3f  public final var hitNormal_changed   : Vector3f = Vector3f .zero
   @SFVec3f  public final var hitPoint_changed    : Vector3f = Vector3f .zero
   @SFVec3d  public final var hitGeoCoord_changed : Vector3d = Vector3d .zero

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initGeospatialObject ()

      types .append (.GeoTouchSensor)

      addField (.inputOutput,    "metadata",            $metadata)
      addField (.initializeOnly, "geoOrigin",           $geoOrigin)
      addField (.initializeOnly, "geoSystem",           $geoSystem)
      addField (.inputOutput,    "description",         $description)
      addField (.inputOutput,    "enabled",             $enabled)
      addField (.outputOnly,     "hitTexCoord_changed", $hitTexCoord_changed)
      addField (.outputOnly,     "hitNormal_changed",   $hitNormal_changed)
      addField (.outputOnly,     "hitPoint_changed",    $hitPoint_changed)
      addField (.outputOnly,     "hitGeoCoord_changed", $hitGeoCoord_changed)
      addField (.outputOnly,     "isOver",              $isOver)
      addField (.outputOnly,     "isActive",            $isActive)
      addField (.outputOnly,     "touchTime",           $touchTime)

      $hitPoint_changed    .unit = .length
      $hitGeoCoord_changed .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GeoTouchSensor
   {
      return GeoTouchSensor (with: executionContext)
   }
}
