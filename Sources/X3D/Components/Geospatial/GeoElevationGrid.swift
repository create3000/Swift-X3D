//
//  GeoElevationGrid.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GeoElevationGrid :
   X3DGeometryNode,
   X3DGeospatialObject,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "GeoElevationGrid" }
   public final override class var component      : String { "Geospatial" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "geometry" }

   // Fields

   @MFString public final var geoSystem       : MFString .Value = ["GD", "WE"]
   @SFNode   public final var geoOrigin       : X3DNode?
   @SFVec3d  public final var geoGridOrigin   : Vector3d = Vector3d .zero
   @SFFloat  public final var yScale          : Float = 1
   @SFInt32  public final var xDimension      : Int32 = 0
   @SFDouble public final var xSpacing        : Double = 1
   @SFInt32  public final var zDimension      : Int32 = 0
   @SFDouble public final var zSpacing        : Double = 1
   @SFBool   public final var solid           : Bool = true
   @SFBool   public final var ccw             : Bool = true
   @SFDouble public final var creaseAngle     : Double = 0
   @SFBool   public final var colorPerVertex  : Bool = true
   @SFBool   public final var normalPerVertex : Bool = true
   @SFNode   public final var color           : X3DNode?
   @SFNode   public final var texCoord        : X3DNode?
   @SFNode   public final var normal          : X3DNode?
   @MFDouble public final var height          : MFDouble .Value = [0, 0]

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initGeospatialObject ()

      types .append (.GeoElevationGrid)

      addField (.inputOutput,    "metadata",        $metadata)
      addField (.initializeOnly, "geoOrigin",       $geoOrigin)
      addField (.initializeOnly, "geoSystem",       $geoSystem)
      addField (.initializeOnly, "geoGridOrigin",   $geoGridOrigin)
      addField (.initializeOnly, "xDimension",      $xDimension)
      addField (.initializeOnly, "zDimension",      $zDimension)
      addField (.initializeOnly, "xSpacing",        $xSpacing)
      addField (.initializeOnly, "zSpacing",        $zSpacing)
      addField (.inputOutput,    "yScale",          $yScale)
      addField (.initializeOnly, "solid",           $solid)
      addField (.initializeOnly, "ccw",             $ccw)
      addField (.initializeOnly, "creaseAngle",     $creaseAngle)
      addField (.initializeOnly, "colorPerVertex",  $colorPerVertex)
      addField (.initializeOnly, "normalPerVertex", $normalPerVertex)
      addField (.inputOutput,    "color",           $color)
      addField (.inputOutput,    "texCoord",        $texCoord)
      addField (.inputOutput,    "normal",          $normal)
      addField (.inputOutput,    "height",          $height)

      $geoGridOrigin .unit = .length
      $creaseAngle   .unit = .angle
      $height        .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GeoElevationGrid
   {
      return GeoElevationGrid (with: executionContext)
   }
}
