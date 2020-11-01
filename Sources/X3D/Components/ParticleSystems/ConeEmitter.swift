//
//  ConeEmitter.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ConeEmitter :
   X3DParticleEmitterNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ConeEmitter" }
   public final override class var component      : String { "ParticleSystems" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "emitter" }

   // Fields

   @SFVec3f public final var position  : Vector3f = Vector3f .zero
   @SFVec3f public final var direction : Vector3f = Vector3f (0, 1, 0)
   @SFFloat public final var angle     : Float = 0.7854

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ConeEmitter)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.inputOutput,    "position",    $position)
      addField (.inputOutput,    "direction",   $direction)
      addField (.inputOutput,    "angle",       $angle)
      addField (.inputOutput,    "speed",       $speed)
      addField (.inputOutput,    "variation",   $variation)
      addField (.initializeOnly, "mass",        $mass)
      addField (.initializeOnly, "surfaceArea", $surfaceArea)

      $position    .unit = .length
      $angle       .unit = .angle
      $speed       .unit = .speed
      $mass        .unit = .mass
      $surfaceArea .unit = .area
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ConeEmitter
   {
      return ConeEmitter (with: executionContext)
   }
}
