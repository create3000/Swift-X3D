//
//  TwoSidedMaterial.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TwoSidedMaterial :
   X3DMaterialNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TwoSidedMaterial" }
   internal final override class var component      : String { "Shape" }
   internal final override class var componentLevel : Int32 { 4 }
   internal final override class var containerField : String { "material" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFBool  public final var separateBackColor    : Bool = false
   @SFFloat public final var ambientIntensity     : Float = 0.2
   @SFColor public final var diffuseColor         : Color3f = Color3f (0.8, 0.8, 0.8)
   @SFColor public final var specularColor        : Color3f = .zero
   @SFColor public final var emissiveColor        : Color3f = .zero
   @SFFloat public final var shininess            : Float = 0.2
   @SFFloat public final var transparency         : Float = 0
   @SFFloat public final var backAmbientIntensity : Float = 0.2
   @SFColor public final var backDiffuseColor     : Color3f = Color3f (0.8, 0.8, 0.8)
   @SFColor public final var backSpecularColor    : Color3f = .zero
   @SFColor public final var backEmissiveColor    : Color3f = .zero
   @SFFloat public final var backShininess        : Float = 0.2
   @SFFloat public final var backTransparency     : Float = 0

   // Properties
   
   private final var frontMaterial = x3d_MaterialParameters ()
   private final var backMaterial  = x3d_MaterialParameters ()

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TwoSidedMaterial)

      addField (.inputOutput, "metadata",             $metadata)
      addField (.inputOutput, "separateBackColor",    $separateBackColor)
      addField (.inputOutput, "ambientIntensity",     $ambientIntensity)
      addField (.inputOutput, "diffuseColor",         $diffuseColor)
      addField (.inputOutput, "specularColor",        $specularColor)
      addField (.inputOutput, "emissiveColor",        $emissiveColor)
      addField (.inputOutput, "shininess",            $shininess)
      addField (.inputOutput, "transparency",         $transparency)
      addField (.inputOutput, "backAmbientIntensity", $backAmbientIntensity)
      addField (.inputOutput, "backDiffuseColor",     $backDiffuseColor)
      addField (.inputOutput, "backSpecularColor",    $backSpecularColor)
      addField (.inputOutput, "backEmissiveColor",    $backEmissiveColor)
      addField (.inputOutput, "backShininess",        $backShininess)
      addField (.inputOutput, "backTransparency",     $backTransparency)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TwoSidedMaterial
   {
      return TwoSidedMaterial (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $ambientIntensity     .addInterest ("set_ambientIntensity",     { $0 .set_ambientIntensity () },     self)
      $diffuseColor         .addInterest ("set_diffuseColor",         { $0 .set_diffuseColor () },         self)
      $specularColor        .addInterest ("set_specularColor",        { $0 .set_specularColor () },        self)
      $emissiveColor        .addInterest ("set_emissiveColor",        { $0 .set_emissiveColor () },        self)
      $shininess            .addInterest ("set_shininess",            { $0 .set_shininess () },            self)
      $transparency         .addInterest ("set_transparency",         { $0 .set_transparency () },         self)
      $backAmbientIntensity .addInterest ("set_backAmbientIntensity", { $0 .set_backAmbientIntensity () }, self)
      $backDiffuseColor     .addInterest ("set_backDiffuseColor",     { $0 .set_backDiffuseColor () },     self)
      $backSpecularColor    .addInterest ("set_backSpecularColor",    { $0 .set_backSpecularColor () },    self)
      $backEmissiveColor    .addInterest ("set_backEmissiveColor",    { $0 .set_backEmissiveColor () },    self)
      $backShininess        .addInterest ("set_backShininess",        { $0 .set_backShininess () },        self)
      $backTransparency     .addInterest ("set_backTransparency",     { $0 .set_backTransparency () },     self)

      set_ambientIntensity ()
      set_diffuseColor ()
      set_specularColor ()
      set_emissiveColor ()
      set_shininess ()
      set_transparency ()
      set_backAmbientIntensity ()
      set_backDiffuseColor ()
      set_backSpecularColor ()
      set_backEmissiveColor ()
      set_backShininess ()
      set_backTransparency ()
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
      
      set_transparent ()
   }
   
   private final func set_backAmbientIntensity ()
   {
      backMaterial .ambientIntensity = clamp (backAmbientIntensity, min: 0, max: 1)
   }
   
   private final func set_backDiffuseColor ()
   {
      backMaterial .diffuseColor = clamp (backDiffuseColor, min: .zero, max: .one)
   }
   
   private final func set_backSpecularColor ()
   {
      backMaterial .specularColor = clamp (backSpecularColor, min: .zero, max: .one)
   }
   
   private final func set_backEmissiveColor ()
   {
      backMaterial .emissiveColor = clamp (backEmissiveColor, min: .zero, max: .one)
   }
   
   private final func set_backShininess ()
   {
      backMaterial .shininess = clamp (backShininess, min: 0, max: 1)
   }
   
   private final func set_backTransparency ()
   {
      backMaterial .transparency = clamp (backTransparency, min: 0, max: 1)
      
      set_transparent ()
   }
   
   private final func set_transparent ()
   {
      setTransparent (transparency > 0 || backTransparency > 0)
   }
   
   // Rendering
   
   internal final override func setUniforms (_ uniforms : UnsafeMutablePointer <x3d_Uniforms>)
   {
      uniforms .pointee .separateBackColor = separateBackColor
      uniforms .pointee .frontMaterial     = frontMaterial
      uniforms .pointee .backMaterial      = separateBackColor ? backMaterial : frontMaterial
   }
}
