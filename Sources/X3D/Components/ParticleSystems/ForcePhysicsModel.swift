//
//  ForcePhysicsModel.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ForcePhysicsModel :
   X3DParticlePhysicsModelNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ForcePhysicsModel" }
   public final override class var component      : String { "ParticleSystems" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "physics" }

   // Fields

   @SFVec3f public final var force : Vector3f = Vector3f (0, -9.8, 0)

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ForcePhysicsModel)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "enabled",  $enabled)
      addField (.inputOutput, "force",    $force)

      $force .unit = .force
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ForcePhysicsModel
   {
      return ForcePhysicsModel (with: executionContext)
   }
}
