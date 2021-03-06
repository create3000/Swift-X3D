//
//  GeoCoordinate.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GeoCoordinate :
   X3DCoordinateNode,
   X3DGeospatialObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "GeoCoordinate" }
   internal final override class var component      : String { "Geospatial" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "coord" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @MFString public final var geoSystem : [String] = ["GD", "WE"]
   @SFNode   public final var geoOrigin : X3DNode?
   @MFVec3d  public final var point     : [Vector3d]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initGeospatialObject ()

      types .append (.GeoCoordinate)

      addField (.inputOutput,    "metadata",  $metadata)
      addField (.initializeOnly, "geoOrigin", $geoOrigin)
      addField (.initializeOnly, "geoSystem", $geoSystem)
      addField (.inputOutput,    "point",     $point)

      $point .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GeoCoordinate
   {
      return GeoCoordinate (with: executionContext)
   }
   
   // Member access
   
   internal final override var isEmpty : Bool { point .isEmpty }
   internal final override var count : Int { point .count }
}
