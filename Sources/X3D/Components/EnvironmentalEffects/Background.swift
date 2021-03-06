//
//  Background.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Background :
   X3DBackgroundNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Background" }
   internal final override class var component      : String { "EnvironmentalEffects" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFString public final var frontUrl  : [String]
   @MFString public final var backUrl   : [String]
   @MFString public final var leftUrl   : [String]
   @MFString public final var rightUrl  : [String]
   @MFString public final var topUrl    : [String]
   @MFString public final var bottomUrl : [String]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Background)

      addField (.inputOutput, "metadata",     $metadata)
      addField (.inputOnly,   "set_bind",     $set_bind)
      addField (.inputOutput, "frontUrl",     $frontUrl)
      addField (.inputOutput, "backUrl",      $backUrl)
      addField (.inputOutput, "leftUrl",      $leftUrl)
      addField (.inputOutput, "rightUrl",     $rightUrl)
      addField (.inputOutput, "topUrl",       $topUrl)
      addField (.inputOutput, "bottomUrl",    $bottomUrl)
      addField (.inputOutput, "skyAngle",     $skyAngle)
      addField (.inputOutput, "skyColor",     $skyColor)
      addField (.inputOutput, "groundAngle",  $groundAngle)
      addField (.inputOutput, "groundColor",  $groundColor)
      addField (.inputOutput, "transparency", $transparency)
      addField (.outputOnly,  "isBound",      $isBound)
      addField (.outputOnly,  "bindTime",     $bindTime)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Background
   {
      return Background (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      let texturePropertiesNode = TextureProperties (with: executionContext!)
      
      texturePropertiesNode .boundaryModeS       = "CLAMP_TO_EDGE"
      texturePropertiesNode .boundaryModeT       = "CLAMP_TO_EDGE"
      texturePropertiesNode .boundaryModeR       = "CLAMP_TO_EDGE"
      texturePropertiesNode .minificationFilter  = "NICEST"
      texturePropertiesNode .magnificationFilter = "NICEST"
      
      texturePropertiesNode .setup ()

      let frontTextureNode  = ImageTexture (with: executionContext!)
      let backTextureNode   = ImageTexture (with: executionContext!)
      let leftTextureNode   = ImageTexture (with: executionContext!)
      let rightTextureNode  = ImageTexture (with: executionContext!)
      let topTextureNode    = ImageTexture (with: executionContext!)
      let bottomTextureNode = ImageTexture (with: executionContext!)
      
      $frontUrl  .addFieldInterest (to: frontTextureNode  .$url)
      $backUrl   .addFieldInterest (to: backTextureNode   .$url)
      $leftUrl   .addFieldInterest (to: leftTextureNode   .$url)
      $rightUrl  .addFieldInterest (to: rightTextureNode  .$url)
      $topUrl    .addFieldInterest (to: topTextureNode    .$url)
      $bottomUrl .addFieldInterest (to: bottomTextureNode .$url)
      
      frontTextureNode  .url = frontUrl
      backTextureNode   .url = backUrl
      leftTextureNode   .url = leftUrl
      rightTextureNode  .url = rightUrl
      topTextureNode    .url = topUrl
      bottomTextureNode .url = bottomUrl
      
      frontTextureNode  .textureProperties = texturePropertiesNode
      backTextureNode   .textureProperties = texturePropertiesNode
      leftTextureNode   .textureProperties = texturePropertiesNode
      rightTextureNode  .textureProperties = texturePropertiesNode
      topTextureNode    .textureProperties = texturePropertiesNode
      bottomTextureNode .textureProperties = texturePropertiesNode

      frontTextureNode  .setup ()
      backTextureNode   .setup ()
      leftTextureNode   .setup ()
      rightTextureNode  .setup ()
      topTextureNode    .setup ()
      bottomTextureNode .setup ()
      
      set_frontTexture  (textureNode: frontTextureNode)
      set_backTexture   (textureNode: backTextureNode)
      set_leftTexture   (textureNode: leftTextureNode)
      set_rightTexture  (textureNode: rightTextureNode)
      set_topTexture    (textureNode: topTextureNode)
      set_bottomTexture (textureNode: bottomTextureNode)
   }
}
