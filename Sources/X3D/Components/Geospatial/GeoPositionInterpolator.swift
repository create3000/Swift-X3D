//
//  GeoPositionInterpolator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GeoPositionInterpolator :
   X3DInterpolatorNode,
   X3DGeospatialObject,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "GeoPositionInterpolator" }
   public final override class var component      : String { "Geospatial" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @MFString public final var geoSystem        : MFString .Value = ["GD", "WE"]
   @SFNode   public final var geoOrigin        : X3DNode?
   @MFVec3d  public final var keyValue         : MFVec3d .Value
   @SFVec3d  public final var value_changed    : Vector3d = Vector3d .zero
   @SFVec3d  public final var geovalue_changed : Vector3d = Vector3d .zero

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initGeospatialObject ()

      types .append (.GeoPositionInterpolator)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.initializeOnly, "geoOrigin",        $geoOrigin)
      addField (.initializeOnly, "geoSystem",        $geoSystem)
      addField (.inputOnly,      "set_fraction",     $set_fraction)
      addField (.inputOutput,    "key",              $key)
      addField (.inputOutput,    "keyValue",         $keyValue)
      addField (.outputOnly,     "value_changed",    $value_changed)
      addField (.outputOnly,     "geovalue_changed", $geovalue_changed)

      $keyValue         .unit = .length
      $value_changed    .unit = .length
      $geovalue_changed .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GeoPositionInterpolator
   {
      return GeoPositionInterpolator (with: executionContext)
   }
}
