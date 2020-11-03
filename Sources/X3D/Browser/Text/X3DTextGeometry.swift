//
//  File.swift
//  
//
//  Created by Holger Seelig on 03.11.20.
//

import Metal
import Foundation

internal class X3DTextGeometry
{
   private final var textNode           : Text
   private final var fontStyleNode      : X3DFontStyleNode
   internal private(set) final var bbox : Box3f = Box3f ()

   internal init (textNode : Text, fontStyleNode : X3DFontStyleNode)
   {
      self .textNode      = textNode
      self .fontStyleNode = fontStyleNode
   }
   
   internal final func update ()
   {
      let numLines = textNode .string .count
      
      textNode .lineBounds .resize (numLines, fillWith: Vector2f .zero)
      
      if numLines == 0
      {
         textNode .origin     = Vector3f .zero
         textNode .textBounds = Vector2f .zero
         bbox                 = Box3f ()
         return
      }
      
      if fontStyleNode .horizontal
      {
         horizontal ()
      }
      else
      {
         vertical ()
      }
   }
   
   private final func horizontal ()
   {
      let font        = CTFontCreateWithName ("HelveticaNeue-UltraLight" as CFString, 72, nil)
      let numLines    = textNode .string .count
      let maxExtent   = max (0, textNode .maxExtent)
      let topToBottom = fontStyleNode .topToBottom
      let scale       = fontStyleNode .scale
      let spacing     = fontStyleNode .spacing
      
      bbox = Box3f ()
            
      // Calculate bboxes.
      
      let first = topToBottom ? 0 : numLines - 1
      let last  = topToBottom ? numLines : -1
      let step  = topToBottom ? 1 : -1
      var ll    = 0

      for l in stride (from: first, to: last, by: step)
      {
         debugPrint (font)
         
         ll += 1
      }
   }
   
   private final func vertical ()
   {
      
   }

   internal func build () { }
   
   // Rendering preparations
   
   internal func traverse (_ type : X3DTraverseType, _ renderer : X3DRenderer) { }
   
   internal func render (_ context : X3DRenderContext, _ renderEncoder : MTLRenderCommandEncoder) { }
}
