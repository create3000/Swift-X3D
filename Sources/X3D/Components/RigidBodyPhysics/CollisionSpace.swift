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
   
   public final override class var typeName       : String { "CollisionSpace" }
   public final override class var component      : String { "RigidBodyPhysics" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool public final var useGeometry : Bool = false
   @MFNode public final var collidables : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
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