//
//  CollisionSpace.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CollisionSpace :
   X3DNBodyCollisionSpaceNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "CollisionSpace" }
   internal final override class var component      : String { "RigidBodyPhysics" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFBool public final var useGeometry : Bool = false
   @MFNode public final var collidables : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.CollisionSpace)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.inputOutput,    "enabled",     $enabled)
      addField (.inputOutput,    "useGeometry", $useGeometry)
      addField (.initializeOnly, "bboxSize",    $bboxSize)
      addField (.initializeOnly, "bboxCenter",  $bboxCenter)
      addField (.inputOutput,    "collidables", $collidables)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CollisionSpace
   {
      return CollisionSpace (with: executionContext)
   }
}
