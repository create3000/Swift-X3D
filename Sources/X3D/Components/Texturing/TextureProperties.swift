//
//  TextureProperties.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public final class TextureProperties :
   X3DNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TextureProperties" }
   internal final override class var component      : String { "Texturing" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFColorRGBA public final var borderColor         : Color4f = Color4f (0, 0, 0, 0)
   @SFInt32     public final var borderWidth         : Int32 = 0
   @SFFloat     public final var anisotropicDegree   : Float = 1
   @SFBool      public final var generateMipMaps     : Bool = false
   @SFString    public final var minificationFilter  : String = "FASTEST"
   @SFString    public final var magnificationFilter : String = "FASTEST"
   @SFString    public final var boundaryModeS       : String = "REPEAT"
   @SFString    public final var boundaryModeT       : String = "REPEAT"
   @SFString    public final var boundaryModeR       : String = "REPEAT"
   @SFString    public final var textureCompression  : String = "FASTEST"
   @SFFloat     public final var texturePriority     : Float = 0

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TextureProperties)

      addField (.inputOutput,    "metadata",            $metadata)
      addField (.inputOutput,    "borderColor",         $borderColor)
      addField (.inputOutput,    "borderWidth",         $borderWidth)
      addField (.inputOutput,    "anisotropicDegree",   $anisotropicDegree)
      addField (.initializeOnly, "generateMipMaps",     $generateMipMaps)
      addField (.inputOutput,    "minificationFilter",  $minificationFilter)
      addField (.inputOutput,    "magnificationFilter", $magnificationFilter)
      addField (.inputOutput,    "boundaryModeS",       $boundaryModeS)
      addField (.inputOutput,    "boundaryModeT",       $boundaryModeT)
      addField (.inputOutput,    "boundaryModeR",       $boundaryModeR)
      addField (.inputOutput,    "textureCompression",  $textureCompression)
      addField (.inputOutput,    "texturePriority",     $texturePriority)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TextureProperties
   {
      return TextureProperties (with: executionContext)
   }
   
   // Sampler state
   
   internal final var samplerState : MTLSamplerState
   {
      let sampler = MTLSamplerDescriptor ()
      
      sampler .normalizedCoordinates = true
      sampler .minFilter             = minFilter
      sampler .magFilter             = magFilter
      sampler .mipFilter             = mipFilter
      sampler .maxAnisotropy         = Int (anisotropicDegree)
      sampler .sAddressMode          = sAddressMode
      sampler .tAddressMode          = tAddressMode
      sampler .rAddressMode          = rAddressMode
      sampler .lodMinClamp           = 0
      sampler .lodMaxClamp           = .greatestFiniteMagnitude

      return browser! .device! .makeSamplerState (descriptor: sampler)!
   }
   
   // Property access
   
   static let minificationFilters : [String : MTLSamplerMinMagFilter] = [
      "AVG_PIXEL_AVG_MIPMAP"         : MTLSamplerMinMagFilter .linear,
      "AVG_PIXEL"                    : MTLSamplerMinMagFilter .linear,
      "AVG_PIXEL_NEAREST_MIPMAP"     : MTLSamplerMinMagFilter .linear,
      "NEAREST_PIXEL_AVG_MIPMAP"     : MTLSamplerMinMagFilter .nearest,
      "NEAREST_PIXEL_NEAREST_MIPMAP" : MTLSamplerMinMagFilter .nearest,
      "NEAREST_PIXEL"                : MTLSamplerMinMagFilter .nearest,
      "NICEST"                       : MTLSamplerMinMagFilter .linear,
      "FASTEST"                      : MTLSamplerMinMagFilter .nearest,
   ]
   
   private final var minFilter : MTLSamplerMinMagFilter
   {
      TextureProperties .minificationFilters [minificationFilter] ?? MTLSamplerMinMagFilter .linear
   }
   
   static let magnificationFilters : [String : MTLSamplerMinMagFilter] = [
      "AVG_PIXEL"     : MTLSamplerMinMagFilter .linear,
      "NEAREST_PIXEL" : MTLSamplerMinMagFilter .nearest,
      "NICEST"        : MTLSamplerMinMagFilter .linear,
      "FASTEST"       : MTLSamplerMinMagFilter .nearest,
   ]
   
   private final var magFilter : MTLSamplerMinMagFilter
   {
      TextureProperties .magnificationFilters [magnificationFilter] ?? MTLSamplerMinMagFilter .linear
   }
   
   static let mipFilters : [String : MTLSamplerMipFilter] = [
      "AVG_PIXEL_AVG_MIPMAP"         : MTLSamplerMipFilter .linear,
      "AVG_PIXEL_NEAREST_MIPMAP"     : MTLSamplerMipFilter .nearest,
      "AVG_PIXEL"                    : MTLSamplerMipFilter .notMipmapped,
      "NEAREST_PIXEL_AVG_MIPMAP"     : MTLSamplerMipFilter .linear,
      "NEAREST_PIXEL_NEAREST_MIPMAP" : MTLSamplerMipFilter .nearest,
      "NEAREST_PIXEL"                : MTLSamplerMipFilter .notMipmapped,
      "NICEST"                       : MTLSamplerMipFilter .nearest,
      "FASTEST"                      : MTLSamplerMipFilter .nearest,
   ]
   
   private final var mipFilter : MTLSamplerMipFilter
   {
      TextureProperties .mipFilters [minificationFilter] ?? MTLSamplerMipFilter .linear
   }
   
   static let boundaryModes : [String : MTLSamplerAddressMode] = [
      "CLAMP"             : MTLSamplerAddressMode .clampToZero,
      "CLAMP_TO_EDGE"     : MTLSamplerAddressMode .clampToEdge,
      "CLAMP_TO_BOUNDARY" : MTLSamplerAddressMode .clampToBorderColor,
      "MIRRORED_REPEAT"   : MTLSamplerAddressMode .mirrorRepeat,
      "REPEAT"            : MTLSamplerAddressMode .repeat,
   ]
   
   private final var sAddressMode : MTLSamplerAddressMode
   {
      TextureProperties .boundaryModes [boundaryModeS] ?? MTLSamplerAddressMode .repeat
   }
   
   private final var tAddressMode : MTLSamplerAddressMode
   {
      TextureProperties .boundaryModes [boundaryModeT] ?? MTLSamplerAddressMode .repeat
   }
   
   private final var rAddressMode : MTLSamplerAddressMode
   {
      TextureProperties .boundaryModes [boundaryModeR] ?? MTLSamplerAddressMode .repeat
   }
}
