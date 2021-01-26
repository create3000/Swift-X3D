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
   
   internal final override class var typeName       : String { "CADFace" }
   internal final override class var component      : String { "CADGeometry" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFString public final var name       : String = ""
   @SFVec3f  public final var bboxSize   : Vector3f = -.one
   @SFVec3f  public final var bboxCenter : Vector3f = .zero
   @SFNode   public final var shape      : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
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
   
   public final var bbox : Box3f { .empty }
}
