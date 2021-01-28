//
//  X3DTexture2DNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public class X3DTexture2DNode :
   X3DTextureNode
{
   // Fields

   @SFBool public final var repeatS           : Bool = true
   @SFBool public final var repeatT           : Bool = true
   @SFNode public final var textureProperties : X3DNode?
   
   // Private fields
   
   private final var texturePropertiesNode : TextureProperties?

   // Properties
   
   internal final var texture : MTLTexture
   {
      didSet
      {
         set_samplerState ()
         addNodeEvent ()
      }
   }
   
   private final var samplerState : MTLSamplerState?

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      self .texture = browser .defaultTexture
      
      super .init (browser, executionContext)

      types .append (.X3DTexture2DNode)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      $repeatS           .addInterest ("set_samplerState",      { $0 .set_samplerState () },      self)
      $repeatT           .addInterest ("set_samplerState",      { $0 .set_samplerState () },      self)
      $textureProperties .addInterest ("set_textureProperties", { $0 .set_textureProperties () }, self)

      set_textureProperties ()
   }
   
   internal final var generateMipMaps : Bool?
   {
      texturePropertiesNode? .generateMipMaps
   }
   
   private final func set_textureProperties ()
   {
      texturePropertiesNode? .removeInterest ("set_samplerState", self)
      
      texturePropertiesNode = textureProperties? .innerNode as? TextureProperties
      
      texturePropertiesNode? .addInterest ("set_samplerState", { $0 .set_samplerState () }, self)
      
      set_samplerState ()
   }
   
   private final func set_samplerState ()
   {
      samplerState = texturePropertiesNode? .samplerState ?? buildSampler ()
   }
   
   private final func buildSampler () -> MTLSamplerState?
   {
      let sampler = MTLSamplerDescriptor ()
      let nearest = max (texture .width, texture .height) < browser! .minTextureSize
      
      sampler .normalizedCoordinates = true
      sampler .minFilter             = nearest ? MTLSamplerMinMagFilter .nearest : MTLSamplerMinMagFilter .linear
      sampler .magFilter             = nearest ? MTLSamplerMinMagFilter .nearest : MTLSamplerMinMagFilter .linear
      sampler .mipFilter             = nearest ? MTLSamplerMipFilter    .nearest : MTLSamplerMipFilter    .linear
      sampler .maxAnisotropy         = 1
      sampler .sAddressMode          = repeatS ? MTLSamplerAddressMode .repeat : MTLSamplerAddressMode .clampToZero
      sampler .tAddressMode          = repeatT ? MTLSamplerAddressMode .repeat : MTLSamplerAddressMode .clampToZero
      sampler .rAddressMode          = MTLSamplerAddressMode .repeat
      sampler .lodMinClamp           = 0
      sampler .lodMaxClamp           = .greatestFiniteMagnitude

      return browser! .device! .makeSamplerState (descriptor: sampler)
   }
   
   internal final override func setFragmentTexture (_ renderEncoder : MTLRenderCommandEncoder, index : Int)
   {
      renderEncoder .setFragmentSamplerState (samplerState, index: index)
      renderEncoder .setFragmentTexture (texture, index: index)
   }
}
