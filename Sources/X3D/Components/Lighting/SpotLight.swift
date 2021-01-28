//
//  SpotLight.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class SpotLight :
   X3DLightNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "SpotLight" }
   internal final override class var component      : String { "Lighting" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFVec3f public final var attenuation : Vector3f = Vector3f (1, 0, 0)
   @SFVec3f public final var location    : Vector3f = .zero
   @SFVec3f public final var direction   : Vector3f = Vector3f (0, 0, -1)
   @SFFloat public final var radius      : Float = 100
   @SFFloat public final var beamWidth   : Float = 0.7854
   @SFFloat public final var cutOffAngle : Float = 1.5708

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.SpotLight)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOutput,    "global",           $global)
      addField (.inputOutput,    "on",               $on)
      addField (.inputOutput,    "color",            $color)
      addField (.inputOutput,    "intensity",        $intensity)
      addField (.inputOutput,    "ambientIntensity", $ambientIntensity)
      addField (.inputOutput,    "attenuation",      $attenuation)
      addField (.inputOutput,    "location",         $location)
      addField (.inputOutput,    "direction",        $direction)
      addField (.inputOutput,    "radius",           $radius)
      addField (.inputOutput,    "beamWidth",        $beamWidth)
      addField (.inputOutput,    "cutOffAngle",      $cutOffAngle)
      addField (.inputOutput,    "shadowColor",      $shadowColor)
      addField (.inputOutput,    "shadowIntensity",  $shadowIntensity)
      addField (.inputOutput,    "shadowBias",       $shadowBias)
      addField (.initializeOnly, "shadowMapSize",    $shadowMapSize)

      $location    .unit = .length
      $radius      .unit = .length
      $beamWidth   .unit = .angle
      $cutOffAngle .unit = .angle
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SpotLight
   {
      return SpotLight (with: executionContext)
   }
   
   // Rendering
   
   internal final override func setUniforms (_ uniforms : UnsafeMutablePointer <x3d_LightSourceParameters>, _ modelViewMatrix : Matrix4f, _ matrix : Matrix3f)
   {
      // If the beamWidth is greater than the cutOffAngle, beamWidth is defined to be equal to the cutOffAngle.
      let cutOffAngle = clamp (self .cutOffAngle, min: 0, max: .pi / 2)
      let beamWidth   = self .beamWidth > cutOffAngle ? cutOffAngle : clamp (self .beamWidth, min: 0, max: .pi / 2)
      
      uniforms .pointee .type             = x3d_SpotLight
      uniforms .pointee .color            = color
      uniforms .pointee .intensity        = clamp (intensity, min: 0, max: 1)
      uniforms .pointee .ambientIntensity = clamp (ambientIntensity, min: 0, max: 1)
      uniforms .pointee .attenuation      = attenuation
      uniforms .pointee .location         = modelViewMatrix * location
      uniforms .pointee .direction        = normalize (modelViewMatrix .submatrix * direction)
      uniforms .pointee .beamWidth        = beamWidth
      uniforms .pointee .cutOffAngle      = cutOffAngle
      uniforms .pointee .radius           = max (0, radius)
      uniforms .pointee .matrix           = matrix
   }
}
