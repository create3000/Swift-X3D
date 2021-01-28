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
   
   internal final override class var typeName       : String { "ForcePhysicsModel" }
   internal final override class var component      : String { "ParticleSystems" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "physics" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFVec3f public final var force : Vector3f = Vector3f (0, -9.8, 0)

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
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
