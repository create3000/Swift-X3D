//
//  File.swift
//  
//
//  Created by Holger Seelig on 06.11.20.
//

import Cocoa
import MetalKit

internal final class ScreenText :
   X3DTextGeometry
{
   // Properties
   
   @SFNode private final var pixelTexture    : PixelTexture!
   internal final override var isTransparent : Bool { true }
   
   private final var matrix : Matrix4f = .identity

   // Construction
   
   internal init (textNode : Text, fontStyleNode : ScreenFontStyle)
   {
      pixelTexture = PixelTexture (with: textNode .executionContext!)

      super .init (textNode: textNode, fontStyleNode: fontStyleNode)
      
      pixelTexture .setTransparent (true)
   }
   
   // Build
   
   internal final override func build ()
   {
      super .build ()
      
      // Make bbox, origin and textBounds.
      
      let offset : Float = 1 // For antialiasing border on bottom and right side

      textNode .textBounds .x = ceil (textNode .textBounds .x) + offset
      textNode .textBounds .y = ceil (textNode .textBounds .y) + offset

      let extents = bbox .extents
      var min     = extents .min
      var max     = extents .max

      min .x -= offset
      min .y -= offset

      switch fontStyleNode .normalizedMajorAlignment
      {
         case .BEGIN, .FIRST:
            min .x = floor (min .x)
            max .x = min .x + textNode .textBounds .x
         case .MIDDLE:
            min .x = round (min .x)
            max .x = min .x + textNode .textBounds .x
         case .END:
            max .x = ceil (max .x)
            min .x = max .x - textNode .textBounds .x;
      }

      switch fontStyleNode .normalizedMinorAlignment
      {
         case .BEGIN, .FIRST:
            max .y = ceil (max .y)
            min .y = max .y - textNode .textBounds .y
         case .MIDDLE:
            max .y = round (max .y)
            min .y = max .y - textNode .textBounds .y
         case .END:
            min .y = floor (min .y)
            max .y = min .y + textNode .textBounds .y
      }

      textNode .origin .x = min .x
      textNode .origin .y = max .y

      bbox = Box3f (min: min, max: max)
      
      // Make geometry.

      textNode .addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], normal: .zAxis, point: Vector3f (min .x, min .y, 0))
      textNode .addPrimitive (texCoords: [Vector4f (1, 0, 0, 1)], normal: .zAxis, point: Vector3f (max .x, min .y, 0))
      textNode .addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], normal: .zAxis, point: Vector3f (max .x, max .y, 0))
      textNode .addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], normal: .zAxis, point: Vector3f (min .x, min .y, 0))
      textNode .addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], normal: .zAxis, point: Vector3f (max .x, max .y, 0))
      textNode .addPrimitive (texCoords: [Vector4f (0, 1, 0, 1)], normal: .zAxis, point: Vector3f (min .x, max .y, 0))

      // Draw text.
      
      guard let font = fontStyleNode .font else { return }
      
      let width  = Int (textNode .textBounds .x)
      let height = Int (textNode .textBounds .y)

      let context = CGContext (data: nil,
                               width: width,
                               height: height,
                               bitsPerComponent: 8,
                               bytesPerRow: 4 * width,
                               space: CGColorSpace .init (name: CGColorSpace .genericRGBLinear)!,
                               bitmapInfo: CGImageAlphaInfo .premultipliedLast .rawValue)!
      
      if fontStyleNode .horizontal
      {
         
      }
      else
      {
         
      }
      
      let cgImage = context .makeImage ()!
      
      debugPrint (cgImage .width, cgImage .height)
      
      // Create texture.
      
      let browser       = fontStyleNode .browser!
      let textureLoader = MTKTextureLoader (device: browser .device!)
      
      let options : [MTKTextureLoader .Option : Any] = [
         .generateMipmaps : Swift .max (width, height) >= 2,
         .SRGB            : false,
      ]
      
      if let texture = try? textureLoader .newTexture (cgImage: cgImage, options: options)
      {
         pixelTexture .texture = texture
      }
      else
      {
         pixelTexture .texture = browser .defaultTexture
      }
   }
   
   // Rendering preparations
   
   internal final override func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      let modelViewMatrix  = renderer .modelViewMatrix .top
      let projectionMatrix = renderer .projectionMatrix .top
      let viewport         = renderer .viewport .last!

      // Determine screenMatrix.
      // Same as in ScreenGroup.

      let screenScale = renderer .layerNode .viewpointNode .getScreenScale (modelViewMatrix .origin, viewport) // in meter/pixel

      let x = normalize (modelViewMatrix .xAxis) * screenScale .x
      let y = normalize (modelViewMatrix .yAxis) * screenScale .y
      let z = normalize (modelViewMatrix .zAxis) * screenScale .z

      var screenMatrix = Matrix4f (columns: (Vector4f (x, 0), Vector4f (y, 0), Vector4f (z, 0), Vector4f (modelViewMatrix .origin, 1)))
      // Snap to whole pixel.

      var screenPoint = ViewVolume .projectPoint (.zero, screenMatrix, projectionMatrix, viewport)

      screenPoint .x = round (screenPoint .x)
      screenPoint .y = round (screenPoint .y)

      screenPoint = ViewVolume .unProjectPoint (screenPoint .x, screenPoint .y, screenPoint .z, screenMatrix, projectionMatrix, viewport);

      screenPoint .z = 0;
      screenMatrix = screenMatrix .translate (screenPoint)

      // Assign modelViewMatrix and calculate relative matrix.

      matrix = modelViewMatrix .inverse * screenMatrix
         
      // Update Text bbox.
      
      textNode .bbox = matrix * bbox
   }
   
   internal final override func render (_ context : RenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      let uniforms = context .uniforms
      
      uniforms .pointee .textureMatrices = (.identity, .identity)
      uniforms .pointee .numTextures     = 1
      
      pixelTexture .setFragmentTexture (renderEncoder)
      
      uniforms .pointee .modelViewMatrix *= matrix
   }
}
