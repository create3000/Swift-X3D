//
//  Material.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import simd

public final class Material :
   X3DMaterialNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Material" }
   public final override class var component      : String { "Shape" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "material" }

   // Fields

   @SFFloat public final var ambientIntensity : Float = 0.2
   @SFColor public final var diffuseColor     : Color3f = Color3f (0.8, 0.8, 0.8)
   @SFColor public final var emissiveColor    : Color3f = Color3f .zero
   @SFFloat public final var shininess        : Float = 0.2
   @SFColor public final var specularColor    : Color3f = Color3f .zero
   @SFFloat public final var transparency     : Float = 0

   // Properties
   
   private final var frontMaterial = x3d_MaterialParameters ()
   
   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Material)

      addField (.inputOutput, "metadata",         $metadata)
      addField (.inputOutput, "ambientIntensity", $ambientIntensity)
      addField (.inputOutput, "diffuseColor",     $diffuseColor)
      addField (.inputOutput, "specularColor",    $specularColor)
      addField (.inputOutput, "emissiveColor",    $emissiveColor)
      addField (.inputOutput, "shininess",        $shininess)
      addField (.inputOutput, "transparency",     $transparency)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Material
   {
      return Material (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $ambientIntensity .addInterest (Material .set_ambientIntensity, self)
      $diffuseColor     .addInterest (Material .set_diffuseColor,     self)
      $specularColor    .addInterest (Material .set_specularColor,    self)
      $emissiveColor    .addInterest (Material .set_emissiveColor,    self)
      $shininess        .addInterest (Material .set_shininess,        self)
      $transparency     .addInterest (Material .set_transparency,     self)
      
      set_ambientIntensity ()
      set_diffuseColor ()
      set_specularColor ()
      set_emissiveColor ()
      set_shininess ()
      set_transparency ()
   }
   
   // Event handlers
   
   private final func set_ambientIntensity ()
   {
      frontMaterial .ambientIntensity = clamp (ambientIntensity, min: 0, max: 1)
   }
   
   private final func set_diffuseColor ()
   {
      frontMaterial .diffuseColor = clamp (diffuseColor, min: Color3f .zero, max: Color3f .one)
   }
   
   private final func set_specularColor ()
   {
      frontMaterial .specularColor = clamp (specularColor, min: Color3f .zero, max: Color3f .one)
   }
   
   private final func set_emissiveColor ()
   {
      frontMaterial .emissiveColor = clamp (emissiveColor, min: Color3f .zero, max: Color3f .one)
   }
   
   private final func set_shininess ()
   {
      frontMaterial .shininess = clamp (shininess, min: 0, max: 1)
   }
   
   private final func set_transparency ()
   {
      frontMaterial .transparency = clamp (transparency, min: 0, max: 1)
      
      setTransparent (transparency > 0)
   }
   
   // Rendering
   
   internal final override func setUniforms (_ uniforms : UnsafeMutablePointer <x3d_Uniforms>)
   {
      uniforms .pointee .separateBackColor = false
      uniforms .pointee .frontMaterial     = frontMaterial
      uniforms .pointee .backMaterial      = frontMaterial
   }
}