//
//  GeoTransform.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GeoTransform :
   X3DGroupingNode,
   X3DGeospatialObject,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "GeoTransform" }
   public final override class var component      : String { "Geospatial" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @MFString   public final var geoSystem        : MFString .Value = ["GD", "WE"]
   @SFNode     public final var geoOrigin        : X3DNode?
   @SFVec3f    public final var translation      : Vector3f = .zero
   @SFRotation public final var rotation         : Rotation4f = .identity
   @SFVec3f    public final var scale            : Vector3f = Vector3f (1, 1, 1)
   @SFRotation public final var scaleOrientation : Rotation4f = .identity
   @SFVec3d    public final var geoCenter        : Vector3d = Vector3d .zero

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initGeospatialObject ()

      types .append (.GeoTransform)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOutput,    "translation",      $translation)
      addField (.inputOutput,    "rotation",         $rotation)
      addField (.inputOutput,    "scale",            $scale)
      addField (.inputOutput,    "scaleOrientation", $scaleOrientation)
      addField (.initializeOnly, "geoOrigin",        $geoOrigin)
      addField (.initializeOnly, "geoSystem",        $geoSystem)
      addField (.inputOutput,    "geoCenter",        $geoCenter)
      addField (.initializeOnly, "bboxSize",         $bboxSize)
      addField (.initializeOnly, "bboxCenter",       $bboxCenter)
      addField (.inputOnly,      "addChildren",      $addChildren)
      addField (.inputOnly,      "removeChildren",   $removeChildren)
      addField (.inputOutput,    "children",         $children)

      $translation .unit = .length
      $geoCenter   .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GeoTransform
   {
      return GeoTransform (with: executionContext)
   }
}
