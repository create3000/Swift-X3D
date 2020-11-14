//
//  GeoViewpoint.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GeoViewpoint :
   X3DViewpointNode,
   X3DGeospatialObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "GeoViewpoint" }
   internal final override class var component      : String { "Geospatial" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @MFString public final var geoSystem        : [String] = ["GD", "WE"]
   @SFNode   public final var geoOrigin        : X3DNode?
   @SFVec3d  public final var position         : Vector3d = Vector3d (0, 0, 100000)
   @SFVec3d  public final var centerOfRotation : Vector3d = Vector3d .zero
   @SFFloat  public final var fieldOfView      : Float = 0.7854
   @SFFloat  public final var speedFactor      : Float = 1
   @MFString public final var navType          : [String] = ["EXAMINE", "ANY"]
   @SFBool   public final var headlight        : Bool = true

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initGeospatialObject ()

      types .append (.GeoViewpoint)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.initializeOnly, "geoOrigin",         $geoOrigin)
      addField (.initializeOnly, "geoSystem",         $geoSystem)
      addField (.inputOnly,      "set_bind",          $set_bind)
      addField (.inputOutput,    "description",       $description)
      addField (.inputOutput,    "position",          $position)
      addField (.inputOutput,    "orientation",       $orientation)
      addField (.inputOutput,    "centerOfRotation",  $centerOfRotation)
      addField (.inputOutput,    "fieldOfView",       $fieldOfView)
      addField (.inputOutput,    "jump",              $jump)
      addField (.inputOutput,    "retainUserOffsets", $retainUserOffsets)
      addField (.inputOutput,    "navType",           $navType)
      addField (.inputOutput,    "headlight",         $headlight)
      addField (.initializeOnly, "speedFactor",       $speedFactor)
      addField (.outputOnly,     "isBound",           $isBound)
      addField (.outputOnly,     "bindTime",          $bindTime)

      $position         .unit = .length
      $centerOfRotation .unit = .length
      $fieldOfView      .unit = .angle
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GeoViewpoint
   {
      return GeoViewpoint (with: executionContext)
   }
}
