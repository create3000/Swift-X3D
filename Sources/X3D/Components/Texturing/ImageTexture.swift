//
//  ImageTexture.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal
import MetalKit

public final class ImageTexture :
   X3DTexture2DNode,
   X3DUrlObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ImageTexture" }
   internal final override class var component      : String { "Texturing" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "texture" }
   
   // Fields
   
   @MFString public final var url : [String]
   
   // X3DUrlObject
   
   public final var loadState = SFEnum <X3DLoadState> (wrappedValue: .NOT_STARTED_STATE)

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initUrlObject ()

      types .append (.ImageTexture)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.inputOutput,    "url",               $url)
      addField (.initializeOnly, "repeatS",           $repeatS)
      addField (.initializeOnly, "repeatT",           $repeatT)
      addField (.initializeOnly, "textureProperties", $textureProperties)
      
      addChildObjects (loadState)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ImageTexture
   {
      return ImageTexture (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $url .addInterest ("set_url", ImageTexture .set_url, self)
      
      requestImmediateLoad ()
   }
   
   // Event handlers
   
   private final func set_url ()
   {
      guard checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.NOT_STARTED_STATE)

      requestImmediateLoad ()
   }

   // Load handling
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.IN_PROGRESS_STATE)

      // Start load.
      
      let url             = self .url .map { URL (string: $0, relativeTo: executionContext! .getWorldURL ()) } .compactMap { $0 }
      let generateMipMaps = self .generateMipMaps

      browser! .imageQueue .sync
      {
         guard let browser = self .browser else { return }
         
         let textureLoader = MTKTextureLoader (device: browser .device!)
         
         for URL in url
         {
            do
            {
               let options : [MTKTextureLoader .Option : Any] = [
                  .generateMipmaps : generateMipMaps ?? true,
                  .origin          : MTKTextureLoader .Origin .flippedVertically,
                  .SRGB            : false,
                  .textureUsage    : MTLTextureUsage .shaderRead .rawValue | MTLTextureUsage .pixelFormatView .rawValue
               ]

               let texture       = try textureLoader .newTexture (URL: URL, options: options, convert: true)
               let isTransparent = texture .isTransparent
               
               //debugPrint (texture .pixelFormatDesctiption, URL .absoluteURL)

               DispatchQueue .main .async
               {
                  self .texture = texture

                  self .setTransparent (isTransparent)
                  self .setLoadState (.COMPLETE_STATE)
                  
                  browser .console .info (t("Done loading image '%@'.", URL .absoluteString))
               }
               
               return
            }
            catch
            {
               browser .console .warn (t("Couldn't load image texture '%@'. %@", URL .absoluteString, error .localizedDescription))
               
               continue
            }
         }
         
         DispatchQueue .main .async
         {
            self .texture = browser .defaultTexture
            self .setTransparent (false)
            self .setLoadState (.FAILED_STATE)
         }
      }
   }
   
   // Property access
   
   public final override var checkTextureLoadState : X3DLoadState { checkLoadState }
}
