//
//  Material.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Material :
   X3DMaterialNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Material" }
   internal final override class var component      : String { "Shape" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "material" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFFloat public final var ambientIntensity : Float = 0.2
   @SFColor public final var diffuseColor     : Color3f = Color3f (0.8, 0.8, 0.8)
   @SFColor public final var emissiveColor    : Color3f = .zero
   @SFFloat public final var shininess        : Float = 0.2
   @SFColor public final var specularColor    : Color3f = .zero
   @SFFloat public final var transparency     : Float = 0

   // Properties
   
   private final var frontMaterial = x3d_MaterialParameters ()
   
   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
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
      
      $ambientIntensity .addInterest ("set_ambientIntensity", { $0 .set_ambientIntensity () }, self)
      $diffuseColor     .addInterest ("set_diffuseColor",     { $0 .set_diffuseColor () },     self)
      $specularColor    .addInterest ("set_specularColor",    { $0 .set_specularColor () },    self)
      $emissiveColor    .addInterest ("set_emissiveColor",    { $0 .set_emissiveColor () },    self)
      $shininess        .addInterest ("set_shininess",        { $0 .set_shininess () },        self)
      $transparency     .addInterest ("set_transparency",     { $0 .set_transparency () },     self)
      
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
      frontMaterial .diffuseColor = clamp (diffuseColor, min: .zero, max: .one)
   }
   
   private final func set_specularColor ()
   {
      frontMaterial .specularColor = clamp (specularColor, min: .zero, max: .one)
   }
   
   private final func set_emissiveColor ()
   {
      frontMaterial .emissiveColor = clamp (emissiveColor, min: .zero, max: .one)
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
