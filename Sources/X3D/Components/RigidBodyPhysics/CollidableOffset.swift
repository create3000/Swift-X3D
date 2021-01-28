//
//  CollidableOffset.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CollidableOffset :
   X3DNBodyCollidableNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "CollidableOffset" }
   internal final override class var component      : String { "RigidBodyPhysics" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFNode public final var collidable : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.CollidableOffset)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.inputOutput,    "enabled",     $enabled)
      addField (.inputOutput,    "translation", $translation)
      addField (.inputOutput,    "rotation",    $rotation)
      addField (.initializeOnly, "bboxSize",    $bboxSize)
      addField (.initializeOnly, "bboxCenter",  $bboxCenter)
      addField (.initializeOnly, "collidable",  $collidable)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CollidableOffset
   {
      return CollidableOffset (with: executionContext)
   }
}
