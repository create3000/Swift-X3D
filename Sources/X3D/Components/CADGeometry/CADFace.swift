//
//  CADFace.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CADFace :
   X3DChildNode,
   X3DProductStructureChildNode,
   X3DBoundedObject,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "CADFace" }
   public final override class var component      : String { "CADGeometry" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFString public final var name       : String = ""
   @SFVec3f  public final var bboxSize   : Vector3f = Vector3f (-1, -1, -1)
   @SFVec3f  public final var bboxCenter : Vector3f = Vector3f .zero
   @SFNode   public final var shape      : X3DNode?

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initProductStructureChildNode ()
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)

      types .append (.CADFace)

      addField (.inputOutput,    "metadata",   $metadata)
      addField (.inputOutput,    "name",       $name)
      addField (.initializeOnly, "bboxSize",   $bboxSize)
      addField (.initializeOnly, "bboxCenter", $bboxCenter)
      addField (.inputOutput,    "shape",      $shape)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CADFace
   {
      return CADFace (with: executionContext)
   }
   
   // Bounded object
   
   public final var bbox : Box3f { Box3f () }
}