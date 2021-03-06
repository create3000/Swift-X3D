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
   
   private final var pixelTexture            : PixelTexture
   private final let pointSize               : Float
   internal final override var isTransparent : Bool { true }
   
   // Construction
   
   internal init (textNode : Text, fontStyleNode : ScreenFontStyle)
   {
      self .pixelTexture = PixelTexture (with: textNode .executionContext!)
      self .pointSize    = fontStyleNode .pointSize

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
      
      //let rectangle = CGRect (x: 0, y: 0, width: width, height: height)
      //context .setFillColor (.black)
      //context .addRect (rectangle)
      //context .drawPath (using: .fill)
      
      let scale = fontStyleNode .scale
 
      context .scaleBy (x: 1, y: -1)
      context .setFillColor (.white)
      context .setFont (CTFontCopyGraphicsFont (font, nil))
      context .setFontSize (CGFloat (scale))
     
      if fontStyleNode .horizontal
      {
         for l in 0 ..< glyphs .count
         {
            let line        = glyphs [l]
            let advances    = font .advances (of: line)
            let charSpacing = charSpacings [l]
            let translation = translations [l]
            var advance     = Float (0)

            for g in 0 ..< line .count
            {
               let glyph = line [g]
               let x     = minorAlignment .x + translation .x - min .x + advance + Float (g) * charSpacing
               let y     = minorAlignment .y + translation .y - max .y

               context .showGlyphs ([glyph], at: [CGPoint (x: CGFloat (x), y: CGFloat (y))])

               // Calculate advance.
   
               advance += Float (advances [g] .width) * scale
            }
         }
      }
      else
      {
         let leftToRight = fontStyleNode .leftToRight
         let topToBottom = fontStyleNode .topToBottom
         let first       = leftToRight ? 0 : textNode .string .count - 1
         let last        = leftToRight ? textNode .string .count  : -1
         let step        = leftToRight ? 1 : -1
         var count       = 0

         for l in stride (from: first, to: last, by: step)
         {
            let line     = glyphs [l]
            let numChars = line .count
            let firstG   = topToBottom ? 0 : numChars - 1
            let lastG    = topToBottom ? numChars : -1
            let stepG    = topToBottom ? 1 : -1

            for g in stride (from: firstG, to: lastG, by: stepG)
            {
               let translation = translations [g + count]
               let x           = minorAlignment .x + translation .x - min .x
               let y           = minorAlignment .y + translation .y - max .y
               
               context .showGlyphs ([line [g]], at: [CGPoint (x: CGFloat (x), y: CGFloat (y))])
            }
            
            count += line .count
         }
      }
      
      let cgImage = context .makeImage ()!
      
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
   
   internal final override func transformLine (_ line : Line3f) -> Line3f { matrix .inverse * line }
   
   internal final override func transformMatrix (_ matrix : Matrix4f) -> Matrix4f { matrix * self .matrix }

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
