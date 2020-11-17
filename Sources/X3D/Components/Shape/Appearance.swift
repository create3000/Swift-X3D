//
//  Appearance.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public final class Appearance :
   X3DAppearanceNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Appearance" }
   internal final override class var component      : String { "Shape" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "appearance" }

   // Fields

   @SFNode public final var pointProperties  : X3DNode?
   @SFNode public final var lineProperties   : X3DNode?
   @SFNode public final var fillProperties   : X3DNode?
   @SFNode public final var material         : X3DNode?
   @SFNode public final var texture          : X3DNode?
   @SFNode public final var textureTransform : X3DNode?
   @MFNode public final var shaders          : [X3DNode?]
   @SFNode public final var blendMode        : X3DNode?
   
   // Properties
   
   @SFNode private final var pointPropertiesNode  : PointProperties?
   @SFNode private final var linePropertiesNode   : LineProperties?
   @SFNode private final var fillPropertiesNode   : FillProperties?
   @SFNode private final var materialNode         : X3DMaterialNode?
   @SFNode private final var textureNode          : X3DTextureNode?
   @SFNode private final var textureTransformNode : X3DTextureTransformNode?
   @MFNode private final var shaderNodes          : [X3DShaderNode?]
   @SFNode private final var shaderNode           : X3DShaderNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Appearance)

      addField (.inputOutput, "metadata",         $metadata)
      addField (.inputOutput, "pointProperties",  $pointProperties)
      addField (.inputOutput, "lineProperties",   $lineProperties)
      addField (.inputOutput, "fillProperties",   $fillProperties)
      addField (.inputOutput, "material",         $material)
      addField (.inputOutput, "texture",          $texture)
      addField (.inputOutput, "textureTransform", $textureTransform)
      addField (.inputOutput, "shaders",          $shaders)
      addField (.inputOutput, "blendMode",        $blendMode)
      
      addChildObjects ($pointPropertiesNode,
                       $linePropertiesNode,
                       $fillPropertiesNode,
                       $materialNode,
                       $textureNode,
                       $textureTransformNode,
                       $shaderNodes,
                       $shaderNode)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Appearance
   {
      return Appearance (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $pointProperties  .addInterest ("set_pointProperties",  Appearance .set_pointProperties,  self)
      $lineProperties   .addInterest ("set_lineProperties",   Appearance .set_lineProperties,   self)
      $fillProperties   .addInterest ("set_fillProperties",   Appearance .set_fillProperties,   self)
      $material         .addInterest ("set_material",         Appearance .set_material,         self)
      $texture          .addInterest ("set_texture",          Appearance .set_texture,          self)
      $textureTransform .addInterest ("set_textureTransform", Appearance .set_textureTransform, self)
      $shaders          .addInterest ("set_shaders",          Appearance .set_shaders,          self)
      
      set_pointProperties ()
      set_lineProperties ()
      set_fillProperties ()
      set_material ()
      set_texture ()
      set_textureTransform ()
      set_shaders ()
   }
   
   // Event handlers
   
   private final func set_pointProperties ()
   {
      pointPropertiesNode = pointProperties? .innerNode as? PointProperties
   }

   private final func set_lineProperties ()
   {
      linePropertiesNode = lineProperties? .innerNode as? LineProperties
   }

   private final func set_fillProperties ()
   {
      fillPropertiesNode? .$isTransparent .removeInterest ("set_transparent", Appearance .set_transparent, self)
      
      fillPropertiesNode = fillProperties? .innerNode as? FillProperties
      
      fillPropertiesNode? .$isTransparent .addInterest ("set_transparent", Appearance .set_transparent, self)
      
      set_transparent ()
   }

   private final func set_material ()
   {
      materialNode? .$isTransparent .removeInterest ("set_transparent", Appearance .set_transparent, self)
      
      materialNode = material? .innerNode as? X3DMaterialNode
      
      materialNode? .$isTransparent .addInterest ("set_transparent", Appearance .set_transparent, self)
      
      set_transparent ()
   }

   private final func set_texture ()
   {
      textureNode? .$isTransparent .removeInterest ("set_transparent", Appearance .set_transparent, self)
      
      textureNode = texture? .innerNode as? X3DTextureNode
      
      textureNode? .$isTransparent .addInterest ("set_transparent", Appearance .set_transparent, self)

      set_transparent ()
   }

   private final func set_textureTransform ()
   {
      textureTransformNode = textureTransform? .innerNode as? X3DTextureTransformNode
   }

   private final func set_shaders ()
   {
      for shaderNode in shaderNodes
      {
         shaderNode! .$isValid        .removeInterest ("set_shader", Appearance .set_shader, self)
         shaderNode! .$activationTime .removeInterest ("set_shader", Appearance .set_shader, self)
      }
      
      shaderNodes .removeAll (keepingCapacity: true)
      
      for shader in shaders
      {
         if let shaderNode = shader? .innerNode as? X3DShaderNode
         {
            shaderNodes .append (shaderNode)
         }
      }
      
      for shaderNode in shaderNodes
      {
         shaderNode! .$isValid        .addInterest ("set_shader", Appearance .set_shader, self)
         shaderNode! .$activationTime .addInterest ("set_shader", Appearance .set_shader, self)
      }

      set_shader ()
   }
   
   private final func set_shader ()
   {
      shaderNode? .deselect ()
      
      shaderNode = nil
      
      for shaderNode in shaderNodes
      {
         if shaderNode! .isValid && shaderNode! .activationTime == browser! .currentTime
         {
            self .shaderNode = shaderNode
            break
         }
      }

      if shaderNode == nil
      {
         for shaderNode in shaderNodes
         {
            if shaderNode! .isValid
            {
               self .shaderNode = shaderNode
               break
            }
         }
      }
      
      shaderNode? .select ()
   }
   
   private final func set_transparent ()
   {
      setTransparent ((fillPropertiesNode? .isTransparent ?? false) ||
                      (materialNode?       .isTransparent ?? false) ||
                      (textureNode?        .isTransparent ?? false))
   }
   
   // Rendering
   
   internal final override func render (_ context : RenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      let uniforms = context .uniforms
      
      // Material
      
      if let materialNode = materialNode
      {
         uniforms .pointee .lighting = true
         
         materialNode .setUniforms (uniforms)
      }
      else
      {
         uniforms .pointee .lighting = false
      }

      // Texture transform
      
      if let textureTransformNode = textureTransformNode
      {
         var textureMatrices = [Matrix4f] ()
         
         textureTransformNode .getTextureMatrix (array: &textureMatrices)
         
         switch textureMatrices .count
         {
            case 0:
               uniforms .pointee .textureMatrices = (.identity, .identity)
            case 1:
               uniforms .pointee .textureMatrices = (textureMatrices [0], textureMatrices [0])
            default:
               uniforms .pointee .textureMatrices = (textureMatrices [0], textureMatrices [1])
         }
      }
      else
      {
         uniforms .pointee .textureMatrices = (.identity, .identity)
      }

      // Texture
      
      if let textureNode = textureNode
      {
         uniforms .pointee .numTextures = Int32 (textureNode .numTextures)
         
         textureNode .setFragmentTexture (renderEncoder)
      }
      else
      {
         uniforms .pointee .numTextures = 0
      }

      // Shader
      
      context .shaderNode = shaderNode
   }
   
   // Destruction
   
   deinit
   {
      guard browser != nil else { return }
      
      shaderNode? .deselect ()
   }
}
