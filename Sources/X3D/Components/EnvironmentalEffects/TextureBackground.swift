//
//  TextureBackground.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TextureBackground :
   X3DBackgroundNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TextureBackground" }
   internal final override class var component      : String { "EnvironmentalEffects" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFNode public final var frontTexture  : X3DNode?
   @SFNode public final var backTexture   : X3DNode?
   @SFNode public final var leftTexture   : X3DNode?
   @SFNode public final var rightTexture  : X3DNode?
   @SFNode public final var topTexture    : X3DNode?
   @SFNode public final var bottomTexture : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TextureBackground)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOnly,   "set_bind",      $set_bind)
      addField (.inputOutput, "skyAngle",      $skyAngle)
      addField (.inputOutput, "skyColor",      $skyColor)
      addField (.inputOutput, "groundAngle",   $groundAngle)
      addField (.inputOutput, "groundColor",   $groundColor)
      addField (.inputOutput, "transparency",  $transparency)
      addField (.outputOnly,  "isBound",       $isBound)
      addField (.outputOnly,  "bindTime",      $bindTime)
      addField (.inputOutput, "frontTexture",  $frontTexture)
      addField (.inputOutput, "backTexture",   $backTexture)
      addField (.inputOutput, "leftTexture",   $leftTexture)
      addField (.inputOutput, "rightTexture",  $rightTexture)
      addField (.inputOutput, "topTexture",    $topTexture)
      addField (.inputOutput, "bottomTexture", $bottomTexture)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TextureBackground
   {
      return TextureBackground (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $frontTexture  .addInterest ("set_frontTexture",  TextureBackground .set_frontTexture,  self)
      $backTexture   .addInterest ("set_backTexture",   TextureBackground .set_backTexture,   self)
      $leftTexture   .addInterest ("set_leftTexture",   TextureBackground .set_leftTexture,   self)
      $rightTexture  .addInterest ("set_rightTexture",  TextureBackground .set_rightTexture,  self)
      $topTexture    .addInterest ("set_topTexture",    TextureBackground .set_topTexture,    self)
      $bottomTexture .addInterest ("set_bottomTexture", TextureBackground .set_bottomTexture, self)
      
      set_frontTexture ()
      set_backTexture ()
      set_leftTexture ()
      set_rightTexture ()
      set_topTexture ()
      set_bottomTexture ()
   }
   
   private final func set_frontTexture ()
   {
      set_frontTexture (textureNode: frontTexture as? X3DTextureNode)
   }
   
   private final func set_backTexture ()
   {
      set_backTexture (textureNode: backTexture as? X3DTextureNode)
   }
   
   private final func set_leftTexture ()
   {
      set_leftTexture (textureNode: leftTexture as? X3DTextureNode)
   }
   
   private final func set_rightTexture ()
   {
      set_rightTexture (textureNode: rightTexture as? X3DTextureNode)
   }
   
   private final func set_topTexture ()
   {
      set_topTexture (textureNode: topTexture as? X3DTextureNode)
   }
   
   private final func set_bottomTexture ()
   {
      set_bottomTexture (textureNode: bottomTexture as? X3DTextureNode)
   }
}
