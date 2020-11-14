//
//  NurbsSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class NurbsSet :
   X3DChildNode,
   X3DBoundedObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "NurbsSet" }
   internal final override class var component      : String { "NURBS" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFFloat public final var tessellationScale : Float = 1
   @SFVec3f public final var bboxSize          : Vector3f = -.one
   @SFVec3f public final var bboxCenter        : Vector3f = .zero
   @MFNode  public final var addGeometry       : [X3DNode?]
   @MFNode  public final var removeGeometry    : [X3DNode?]
   @MFNode  public final var geometry          : [X3DNode?]

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)

      types .append (.NurbsSet)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.inputOutput,    "tessellationScale", $tessellationScale)
      addField (.initializeOnly, "bboxSize",          $bboxSize)
      addField (.initializeOnly, "bboxCenter",        $bboxCenter)
      addField (.inputOnly,      "addGeometry",       $addGeometry)
      addField (.inputOnly,      "removeGeometry",    $removeGeometry)
      addField (.inputOutput,    "geometry",          $geometry)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> NurbsSet
   {
      return NurbsSet (with: executionContext)
   }
   
   // Bounded object
   
   public final var bbox : Box3f { .empty }
}
