//
//  PixelTexture.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal
import MetalKit
import SwiftImage

public final class PixelTexture :
   X3DTexture2DNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "PixelTexture" }
   internal final override class var component      : String { "Texturing" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "texture" }

   // Fields

   @SFImage public final var image : X3DImage

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PixelTexture)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.inputOutput,    "image",             $image)
      addField (.initializeOnly, "repeatS",           $repeatS)
      addField (.initializeOnly, "repeatT",           $repeatT)
      addField (.initializeOnly, "textureProperties", $textureProperties)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PixelTexture
   {
      return PixelTexture (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $image .addInterest ("set_image", PixelTexture .set_image, self)
      
      DispatchQueue .main .async
      {
         self .set_image ()
      }
   }
   
   // Event handlers
   
   private final func set_image ()
   {
      guard let browser = browser else { return }
      
      let width  = Int (image .width)
      let height = Int (image .height)
      let comp   = Int (image .comp)
      let array  = image .array
      
      guard width > 0 && height > 0 && comp >= 1 && comp <= 4 else
      {
         self .texture = browser .defaultTexture
         self .setTransparent (false)
         
         return
      }
      
      // Create swifty image.
      
      var swifty = Image <RGBA <UInt8>> (width: width, height: height, pixels: Array (repeating: RGBA <UInt8> .transparent, count: width * height))
      
      switch comp
      {
         case 1: do
         {
            for h in 0 ..< height
            {
               let row = h * width
               
               for w in 0 ..< width
               {
                  let v : UInt8 = UInt8 (array [w + row] & 255)
                  
                  swifty [w, h] = RGBA <UInt8> (red: v, green: v, blue: v)
               }
            }
         }
         case 2: do
         {
            for h in 0 ..< height
            {
               let row = h * width
               
               for w in 0 ..< width
               {
                  let p = UInt32 (array [w + row])
                  let v = UInt8 (p >> 8 & 255)
                  let a = UInt8 (p      & 255)
                  
                  swifty [w, h] = RGBA <UInt8> (red: v, green: v, blue: v, alpha: a)
               }
            }
         }
         case 3: do
         {
            for h in 0 ..< height
            {
               let row = h * width
               
               for w in 0 ..< width
               {
                  let p = UInt32 (array [w + row])
                  let r = UInt8 (p >> 16 & 255)
                  let g = UInt8 (p >> 8  & 255)
                  let b = UInt8 (p       & 255)

                  swifty [w, h] = RGBA <UInt8> (red: r, green: g, blue: b)
               }
            }
         }
         case 4: do
         {
            for h in 0 ..< height
            {
               let row = h * width
               
               for w in 0 ..< width
               {
                  let p = UInt32 (array [w + row])
                  let r = UInt8 (p >> 24 & 255)
                  let g = UInt8 (p >> 16 & 255)
                  let b = UInt8 (p >> 8  & 255)
                  let a = UInt8 (p       & 255)

                  swifty [w, h] = RGBA <UInt8> (red: r, green: g, blue: b, alpha: a)
               }
            }
         }
         default:
            break
      }
      
      // Create texture.
      
      let textureLoader = MTKTextureLoader (device: browser .device!)
      
      let options : [MTKTextureLoader .Option : Any] = [
         .generateMipmaps : generateMipMaps,
         .SRGB            : false,
      ]
      
      guard let texture = try? textureLoader .newTexture (cgImage: swifty .cgImage, options: options) else
      {
         browser .console .warn (t("Couldn't load pixel texture. Couldn't make texture from image."))
         
         self .texture = browser .defaultTexture
         self .setTransparent (false)
         
         return
      }
      
      // Set texture.
      
      self .texture = texture
      self .setTransparent (comp & 1 == 0 && swifty .isTransparent)
   }
}

internal extension Image
   where Pixel == RGBA <UInt8>
{
   var isTransparent : Bool { contains { $0 .alpha < 255 } }
}

internal extension RGBA
   where Channel == UInt8
{
   static var transparent : RGBA { RGBA (red: 0, green: 0, blue: 0, alpha: 0) }
   static var black       : RGBA { RGBA (red: 0, green: 0, blue: 0) }
   static var white       : RGBA { RGBA (red: 255, green: 255, blue: 255) }
}
