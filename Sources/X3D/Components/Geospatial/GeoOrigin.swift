//
//  GeoOrigin.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GeoOrigin :
   X3DNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "GeoOrigin" }
   internal final override class var component      : String { "Geospatial" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "geoOrigin" }

   // Fields

   @SFBool   public final var rotateYUp : Bool = false
   @MFString public final var geoSystem : MFString .Value = ["GD", "WE"]
   @SFVec3d  public final var geoCoords : Vector3d = Vector3d .zero

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.GeoOrigin)

      addField (.inputOutput,    "metadata",  $metadata)
      addField (.initializeOnly, "geoSystem", $geoSystem)
      addField (.inputOutput,    "geoCoords", $geoCoords)
      addField (.initializeOnly, "rotateYUp", $rotateYUp)

      $geoCoords .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GeoOrigin
   {
      return GeoOrigin (with: executionContext)
   }
}
