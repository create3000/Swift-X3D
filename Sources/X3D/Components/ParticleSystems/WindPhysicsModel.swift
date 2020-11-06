//
//  WindPhysicsModel.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class WindPhysicsModel :
   X3DParticlePhysicsModelNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "WindPhysicsModel" }
   public final override class var component      : String { "ParticleSystems" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "physics" }

   // Fields

   @SFVec3f public final var direction  : Vector3f = .zero
   @SFFloat public final var speed      : Float = 0.1
   @SFFloat public final var gustiness  : Float = 0.1
   @SFFloat public final var turbulence : Float = 0

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.WindPhysicsModel)

      addField (.inputOutput, "metadata",   $metadata)
      addField (.inputOutput, "enabled",    $enabled)
      addField (.inputOutput, "direction",  $direction)
      addField (.inputOutput, "speed",      $speed)
      addField (.inputOutput, "gustiness",  $gustiness)
      addField (.inputOutput, "turbulence", $turbulence)

      $speed .unit = .speed
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> WindPhysicsModel
   {
      return WindPhysicsModel (with: executionContext)
   }
}
