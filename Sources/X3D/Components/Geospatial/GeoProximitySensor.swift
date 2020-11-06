//
//  GeoProximitySensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GeoProximitySensor :
   X3DEnvironmentalSensorNode,
   X3DGeospatialObject,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "GeoProximitySensor" }
   public final override class var component      : String { "Geospatial" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @MFString   public final var geoSystem                : MFString .Value = ["GD", "WE"]
   @SFNode     public final var geoOrigin                : X3DNode?
   @SFVec3d    public final var geoCoord_changed         : Vector3d = Vector3d .zero
   @SFVec3f    public final var position_changed         : Vector3f = .zero
   @SFRotation public final var orientation_changed      : Rotation4f = .identity
   @SFVec3f    public final var centerOfRotation_changed : Vector3f = .zero

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initGeospatialObject ()

      types .append (.GeoProximitySensor)

      addField (.inputOutput,    "metadata",                 $metadata)
      addField (.initializeOnly, "geoOrigin",                $geoOrigin)
      addField (.initializeOnly, "geoSystem",                $geoSystem)
      addField (.inputOutput,    "enabled",                  $enabled)
      addField (.inputOutput,    "size",                     $size)
      addField (.inputOutput,    "center",                   $center)
      addField (.outputOnly,     "isActive",                 $isActive)
      addField (.outputOnly,     "enterTime",                $enterTime)
      addField (.outputOnly,     "exitTime",                 $exitTime)
      addField (.outputOnly,     "geoCoord_changed",         $geoCoord_changed)
      addField (.outputOnly,     "position_changed",         $position_changed)
      addField (.outputOnly,     "orientation_changed",      $orientation_changed)
      addField (.outputOnly,     "centerOfRotation_changed", $centerOfRotation_changed)

      $geoCoord_changed         .unit = .length
      $position_changed         .unit = .length
      $centerOfRotation_changed .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GeoProximitySensor
   {
      return GeoProximitySensor (with: executionContext)
   }
}
