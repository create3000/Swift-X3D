//
//  SurfaceEmitter.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class SurfaceEmitter :
   X3DParticleEmitterNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "SurfaceEmitter" }
   public final override class var component      : String { "ParticleSystems" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "emitter" }

   // Fields

   @SFNode public final var surface : X3DNode?

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.SurfaceEmitter)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.inputOutput,    "speed",       $speed)
      addField (.inputOutput,    "variation",   $variation)
      addField (.initializeOnly, "mass",        $mass)
      addField (.initializeOnly, "surfaceArea", $surfaceArea)
      addField (.initializeOnly, "surface",     $surface)

      $speed       .unit = .speed
      $mass        .unit = .mass
      $surfaceArea .unit = .area
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SurfaceEmitter
   {
      return SurfaceEmitter (with: executionContext)
   }
}