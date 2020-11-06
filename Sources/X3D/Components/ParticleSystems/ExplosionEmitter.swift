//
//  ExplosionEmitter.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ExplosionEmitter :
   X3DParticleEmitterNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ExplosionEmitter" }
   public final override class var component      : String { "ParticleSystems" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "emitter" }

   // Fields

   @SFVec3f public final var position : Vector3f = .zero

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ExplosionEmitter)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.inputOutput,    "position",    $position)
      addField (.inputOutput,    "speed",       $speed)
      addField (.inputOutput,    "variation",   $variation)
      addField (.initializeOnly, "mass",        $mass)
      addField (.initializeOnly, "surfaceArea", $surfaceArea)

      $position    .unit = .length
      $speed       .unit = .speed
      $mass        .unit = .mass
      $surfaceArea .unit = .area
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ExplosionEmitter
   {
      return ExplosionEmitter (with: executionContext)
   }
}
