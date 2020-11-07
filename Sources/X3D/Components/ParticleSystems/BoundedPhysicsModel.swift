//
//  BoundedPhysicsModel.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class BoundedPhysicsModel :
   X3DParticlePhysicsModelNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "BoundedPhysicsModel" }
   internal final override class var component      : String { "ParticleSystems" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "physics" }

   // Fields

   @SFNode public final var geometry : X3DNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.BoundedPhysicsModel)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "enabled",  $enabled)
      addField (.inputOutput, "geometry", $geometry)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> BoundedPhysicsModel
   {
      return BoundedPhysicsModel (with: executionContext)
   }
}
