//
//  CollidableShape.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CollidableShape :
   X3DNBodyCollidableNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "CollidableShape" }
   internal final override class var component      : String { "RigidBodyPhysics" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFNode public final var shape : X3DNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.CollidableShape)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.inputOutput,    "enabled",     $enabled)
      addField (.inputOutput,    "translation", $translation)
      addField (.inputOutput,    "rotation",    $rotation)
      addField (.initializeOnly, "bboxSize",    $bboxSize)
      addField (.initializeOnly, "bboxCenter",  $bboxCenter)
      addField (.initializeOnly, "shape",       $shape)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CollidableShape
   {
      return CollidableShape (with: executionContext)
   }
}
