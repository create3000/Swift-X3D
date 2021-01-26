//
//  PolylineEmitter.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PolylineEmitter :
   X3DParticleEmitterNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "PolylineEmitter" }
   internal final override class var component      : String { "ParticleSystems" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFVec3f public final var direction  : Vector3f = Vector3f (0, 1, 0)
   @MFInt32 public final var coordIndex : [Int32] = [-1]
   @SFNode  public final var coord      : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PolylineEmitter)

      addField (.inputOutput,    "metadata",       $metadata)
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

   internal final override func create (with executionContext : X3DExecutionContext) -> PolylineEmitter
   {
      return PolylineEmitter (with: executionContext)
   }
}
