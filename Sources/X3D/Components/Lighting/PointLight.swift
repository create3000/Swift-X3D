//
//  PointLight.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PointLight :
   X3DLightNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "PointLight" }
   public final override class var component      : String { "Lighting" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFVec3f public final var attenuation : Vector3f = Vector3f (1, 0, 0)
   @SFVec3f public final var location    : Vector3f = .zero
   @SFFloat public final var radius      : Float = 100

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PointLight)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOutput,    "global",           $global)
      addField (.inputOutput,    "on",               $on)
      addField (.inputOutput,    "color",            $color)
      addField (.inputOutput,    "intensity",        $intensity)
      addField (.inputOutput,    "ambientIntensity", $ambientIntensity)
      addField (.inputOutput,    "attenuation",      $attenuation)
      addField (.inputOutput,    "location",         $location)
      addField (.inputOutput,    "radius",           $radius)
      addField (.inputOutput,    "shadowColor",      $shadowColor)
      addField (.inputOutput,    "shadowIntensity",  $shadowIntensity)
      addField (.inputOutput,    "shadowBias",       $shadowBias)
      addField (.initializeOnly, "shadowMapSize",    $shadowMapSize)

      $location .unit = .length
      $radius   .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PointLight
   {
      return PointLight (with: executionContext)
   }
   
   // Rendering
   
   internal final override func setUniforms (_ uniforms : UnsafeMutablePointer <x3d_LightSourceParameters>, _ modelViewMatrix : Matrix4f, _ matrix : Matrix3f)
   {
      uniforms .pointee .type             = x3d_PointLight
      uniforms .pointee .color            = color
      uniforms .pointee .intensity        = clamp (intensity, min: 0, max: 1)
      uniforms .pointee .ambientIntensity = clamp (ambientIntensity, min: 0, max: 1)
      uniforms .pointee .attenuation      = attenuation
      uniforms .pointee .location         = modelViewMatrix * location
      uniforms .pointee .radius           = max (0, radius)
      uniforms .pointee .matrix           = matrix
   }
}
