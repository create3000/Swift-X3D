//
//  PointEmitter.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PointEmitter :
   X3DParticleEmitterNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "PointEmitter" }
   internal final override class var component      : String { "ParticleSystems" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "emitter" }

   // Fields

   @SFVec3f public final var position  : Vector3f = .zero
   @SFVec3f public final var direction : Vector3f = Vector3f (0, 1, 0)

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PointEmitter)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.inputOutput,    "position",    $position)
      addField (.inputOutput,    "direction",   $direction)
      addField (.inputOutput,    "speed",       $speed)
      addField (.inputOutput,    "variation",   $variation)
      addField (.initializeOnly, "mass",        $mass)
      addField (.initializeOnly, "surfaceArea", $surfaceArea)

      $position    .unit = .length
      $speed       .unit = .speed
      $mass        .unit = .mass
      $surfaceArea .unit = .area
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PointEmitter
   {
      return PointEmitter (with: executionContext)
   }
}
