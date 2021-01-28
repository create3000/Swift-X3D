//
//  DirectionalLight.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class DirectionalLight :
   X3DLightNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "DirectionalLight" }
   internal final override class var component      : String { "Lighting" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFVec3f public final var direction : Vector3f = Vector3f (0, 0, -1)

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.DirectionalLight)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOutput,    "global",           $global)
      addField (.inputOutput,    "on",               $on)
      addField (.inputOutput,    "color",            $color)
      addField (.inputOutput,    "intensity",        $intensity)
      addField (.inputOutput,    "ambientIntensity", $ambientIntensity)
      addField (.inputOutput,    "direction",        $direction)
      addField (.inputOutput,    "shadowColor",      $shadowColor)
      addField (.inputOutput,    "shadowIntensity",  $shadowIntensity)
      addField (.inputOutput,    "shadowBias",       $shadowBias)
      addField (.initializeOnly, "shadowMapSize",    $shadowMapSize)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> DirectionalLight
   {
      return DirectionalLight (with: executionContext)
   }
   
   // Rendering
   
   internal final override func setUniforms (_ uniforms : UnsafeMutablePointer <x3d_LightSourceParameters>, _ modelViewMatrix : Matrix4f, _ matrix : Matrix3f)
   {
      uniforms .pointee .type             = x3d_DirectionalLight
      uniforms .pointee .color            = color
      uniforms .pointee .intensity        = clamp (intensity, min: 0, max: 1)
      uniforms .pointee .ambientIntensity = clamp (ambientIntensity, min: 0, max: 1)
      uniforms .pointee .direction        = normalize (modelViewMatrix .submatrix * direction)
      uniforms .pointee .matrix           = matrix
   }
}
