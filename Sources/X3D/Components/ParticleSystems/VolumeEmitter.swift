//
//  VolumeEmitter.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class VolumeEmitter :
   X3DParticleEmitterNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "VolumeEmitter" }
   public final override class var component      : String { "ParticleSystems" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "emitter" }

   // Fields

   @SFBool  public final var `internal` : Bool = true
   @SFVec3f public final var direction  : Vector3f = Vector3f (0, 1, 0)
   @MFInt32 public final var coordIndex : MFInt32 .Value = [-1]
   @SFNode  public final var coord      : X3DNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.VolumeEmitter)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.initializeOnly, "internal",       $internal)
      addField (.inputOutput,    "direction",      $direction)
      addField (.inputOutput,    "speed",          $speed)
      addField (.inputOutput,    "variation",      $variation)
      addField (.initializeOnly, "mass",           $mass)
      addField (.initializeOnly, "surfaceArea",    $surfaceArea)
      addField (.inputOutput,    "coordIndex",     $coordIndex)
      addField (.inputOutput,    "coord",          $coord)

      $speed       .unit = .speed
      $mass        .unit = .mass
      $surfaceArea .unit = .area
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> VolumeEmitter
   {
      return VolumeEmitter (with: executionContext)
   }
}
