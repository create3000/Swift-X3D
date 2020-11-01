//
//  ParticleSystem.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class ParticleSystem :
   X3DShapeNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ParticleSystem" }
   public final override class var component      : String { "ParticleSystems" }
   public final override class var componentLevel : Int32 { 3 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool   public final var enabled           : Bool = true
   @SFString public final var geometryType      : String = "QUAD"
   @SFBool   public final var createParticles   : Bool = true
   @SFInt32  public final var maxParticles      : Int32 = 200
   @SFFloat  public final var particleLifetime  : Float = 5
   @SFFloat  public final var lifetimeVariation : Float = 0.25
   @SFVec2f  public final var particleSize      : Vector2f = Vector2f (0.02, 0.02)
   @MFFloat  public final var colorKey          : MFFloat .Value
   @MFFloat  public final var texCoordKey       : MFFloat .Value
   @SFBool   public final var isActive          : Bool = false
   @SFNode   public final var emitter           : X3DNode?
   @SFNode   public final var colorRamp         : X3DNode?
   @SFNode   public final var texCoordRamp      : X3DNode?
   @MFNode   public final var physics           : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      types .append (.ParticleSystem)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.inputOutput,    "enabled",           $enabled)
      addField (.initializeOnly, "geometryType",      $geometryType)
      addField (.inputOutput,    "maxParticles",      $maxParticles)
      addField (.inputOutput,    "createParticles",   $createParticles)
      addField (.inputOutput,    "particleLifetime",  $particleLifetime)
      addField (.inputOutput,    "lifetimeVariation", $lifetimeVariation)
      addField (.inputOutput,    "particleSize",      $particleSize)
      addField (.initializeOnly, "emitter",           $emitter)
      addField (.initializeOnly, "physics",           $physics)
      addField (.initializeOnly, "colorKey",          $colorKey)
      addField (.initializeOnly, "colorRamp",         $colorRamp)
      addField (.initializeOnly, "texCoordKey",       $texCoordKey)
      addField (.initializeOnly, "texCoordRamp",      $texCoordRamp)
      addField (.outputOnly,     "isActive",          $isActive)
      addField (.initializeOnly, "bboxSize",          $bboxSize)
      addField (.initializeOnly, "bboxCenter",        $bboxCenter)
      addField (.inputOutput,    "appearance",        $appearance)
      addField (.inputOutput,    "geometry",          $geometry)

      $particleSize .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ParticleSystem
   {
      return ParticleSystem (with: executionContext)
   }
}
