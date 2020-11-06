//
//  GeoLOD.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GeoLOD :
   X3DChildNode,
   X3DGeospatialObject,
   X3DBoundedObject,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "GeoLOD" }
   public final override class var component      : String { "Geospatial" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @MFString public final var geoSystem     : MFString .Value = ["GD", "WE"]
   @SFNode   public final var geoOrigin     : X3DNode?
   @MFString public final var rootUrl       : MFString .Value
   @MFString public final var child1Url     : MFString .Value
   @MFString public final var child2Url     : MFString .Value
   @MFString public final var child3Url     : MFString .Value
   @MFString public final var child4Url     : MFString .Value
   @SFVec3d  public final var center        : Vector3d = Vector3d .zero
   @SFFloat  public final var range         : Float = 10
   @SFInt32  public final var level_changed : Int32 = -1
   @SFVec3f  public final var bboxSize      : Vector3f = -.one
   @SFVec3f  public final var bboxCenter    : Vector3f = .zero
   @MFNode   public final var rootNode      : MFNode <X3DNode> .Value
   @MFNode   public final var children      : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initGeospatialObject ()
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)

      types .append (.GeoLOD)

      addField (.inputOutput,    "metadata",      $metadata)
      addField (.initializeOnly, "geoOrigin",     $geoOrigin)
      addField (.initializeOnly, "geoSystem",     $geoSystem)
      addField (.initializeOnly, "rootUrl",       $rootUrl)
      addField (.initializeOnly, "child1Url",     $child1Url)
      addField (.initializeOnly, "child2Url",     $child2Url)
      addField (.initializeOnly, "child3Url",     $child3Url)
      addField (.initializeOnly, "child4Url",     $child4Url)
      addField (.initializeOnly, "center",        $center)
      addField (.initializeOnly, "range",         $range)
      addField (.outputOnly,     "level_changed", $level_changed)
      addField (.initializeOnly, "bboxSize",      $bboxSize)
      addField (.initializeOnly, "bboxCenter",    $bboxCenter)
      addField (.initializeOnly, "rootNode",      $rootNode)
      addField (.outputOnly,     "children",      $children)

      $center .unit = .length
      $range  .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GeoLOD
   {
      return GeoLOD (with: executionContext)
   }
   
   // Bounded object
   
   public final var bbox : Box3f { Box3f () }
}
