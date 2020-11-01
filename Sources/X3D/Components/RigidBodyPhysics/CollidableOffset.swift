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
   
   public final override class var typeName       : String { "CollidableOffset" }
   public final override class var component      : String { "RigidBodyPhysics" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFNode public final var collidable : X3DNode?

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
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
