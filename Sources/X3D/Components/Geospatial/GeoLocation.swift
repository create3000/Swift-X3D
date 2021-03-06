//
//  GeoLocation.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GeoLocation :
   X3DGroupingNode,
   X3DGeospatialObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "GeoLocation" }
   internal final override class var component      : String { "Geospatial" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @MFString public final var geoSystem : [String] = ["GD", "WE"]
   @SFNode   public final var geoOrigin : X3DNode?
   @SFVec3d  public final var geoCoords : Vector3d = Vector3d .zero

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initGeospatialObject ()

      types .append (.GeoLocation)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.initializeOnly, "geoOrigin",      $geoOrigin)
      addField (.initializeOnly, "geoSystem",      $geoSystem)
      addField (.inputOutput,    "geoCoords",      $geoCoords)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)

      $geoCoords .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GeoLocation
   {
      return GeoLocation (with: executionContext)
   }
}
