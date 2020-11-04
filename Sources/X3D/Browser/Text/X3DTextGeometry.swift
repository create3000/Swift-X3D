//
//  File.swift
//  
//
//  Created by Holger Seelig on 03.11.20.
//

import Metal
import Foundation
import CoreTextSwift

internal class X3DTextGeometry
{
   internal private(set) final var textNode       : Text
   internal private(set) final var fontStyleNode  : X3DFontStyleNode
   internal private(set) final var bbox           : Box3f = Box3f ()
   internal private(set) final var glyphs         : [[CGGlyph]] = [ ]
   internal private(set) final var charSpacings   : [Float] = [ ]
   internal private(set) final var translations   : [Vector2f] = [ ]
   internal private(set) final var minorAlignment : Vector2f = Vector2f .zero

   internal init (textNode : Text, fontStyleNode : X3DFontStyleNode)
   {
      self .textNode      = textNode
      self .fontStyleNode = fontStyleNode
   }
   
   internal final func update ()
   {
      let numLines = textNode .string .count
      
      textNode .lineBounds .resize (numLines, fillWith: Vector2f .zero)
      
      glyphs       = [[CGGlyph]] (repeating: [ ], count: numLines)
      charSpacings = [Float] (repeating: 0, count: numLines)
      translations = [Vector2f] (repeating: Vector2f .zero, count: numLines)

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
      guard let font = fontStyleNode .font else { return }
      
      let numLines    = textNode .string .count
      let maxExtent   = max (0, textNode .maxExtent)
      let topToBottom = fontStyleNode .topToBottom
      let spacing     = fontStyleNode .spacing
      let scale       = fontStyleNode .scale
      
      var bbox = Box2f ()
            
      // Calculate bboxes.
      
      let first = topToBottom ? 0 : numLines - 1
      let last  = topToBottom ? numLines : -1
      let step  = topToBottom ? 1 : -1
      var ll    = 0

      for l in stride (from: first, to: last, by: step)
      {
         let line = fontStyleNode .leftToRight ? textNode .string [l] : String (textNode .string [l] .reversed ())
         
         // Get line extents.
         
         let extents = horizontalLineExtents (lineNumber: ll, string: line, font: font)
         var size    = extents .max - extents .min
         
         // Calculate charSpacing and lineBounds.
         
         var charSpacing = Float (0)
         var length      = textNode .length (index: l)
         var lineBound   = Vector2f (size .x, ll == 0 ? extents .max .y - Float (font .descent ()) : spacing) * scale

         if maxExtent > 0
         {
            if length > 0
            {
               length = min (maxExtent, length)
            }
            else
            {
               length = min (maxExtent, size .x * scale)
            }
         }
         
         if length > 0
         {
            charSpacing  = (length - lineBound .x) / Float (glyphs [ll] .count - 1)
            lineBound .x = length
            size .x      = length / scale
         }
         
         charSpacings [ll]        = charSpacing
         textNode .lineBounds [l] = lineBound
         
         // Calculate line translation.

         switch fontStyleNode .normalizedMajorAlignment
         {
            case .BEGIN, .FIRST:
               translations [ll] = Vector2f (0, Float (-ll) * spacing)
            case .MIDDLE:
               translations [ll] = Vector2f (-extents .min .x - size .x / 2, Float (-ll) * spacing)
            case .END:
               translations [ll] = Vector2f (-extents .min .x - size .x, Float (-ll) * spacing)
         }
         
         translations [ll] *= scale

         // Calculate center.

         let center = extents .min + size / 2
         
         bbox += Box2f (size: size * scale, center: center * scale + translations [ll])
                  
         ll += 1
      }
      
      // Get text extents.

      var extents = bbox .extents
      let size    = bbox .size
      
      // Calculate text position

      textNode .textBounds = size
      
      let bearing = Vector2f (0, -extents .max .y)

      switch fontStyleNode .normalizedMinorAlignment
      {
         case .BEGIN:
            minorAlignment = bearing
         case .FIRST:
            minorAlignment = Vector2f .zero
         case .MIDDLE:
            minorAlignment = Vector2f (0, size .y / 2 - extents .max .y)
         case .END:
            minorAlignment = Vector2f (0, Float (numLines - 1) * (spacing * scale))
      }
      
      // Translate bbox by minorAlignment.
      
      extents .min += minorAlignment
      extents .max += minorAlignment
      
      // The value of the origin field represents the upper left corner of the textBounds.

      textNode .origin = Vector3f (extents .min .x, extents .max .y, 0)
      
      self .bbox = Box3f (min: Vector3f (extents .min .x, extents .min .y, 0),
                          max: Vector3f (extents .max .x, extents .max .y, 0));
   }
   
   private final func horizontalLineExtents (lineNumber : Int, string : String, font : CTFont) -> (min : Vector2f, max : Vector2f)
   {
      let attributedString = CFAttributedStringCreate (nil, string as CFString, [kCTFontAttributeName : font] as CFDictionary)
      let glyphs           = attributedString! .glyphs ()
      let advances         = font .advances (of: glyphs)
      let rects            = font .boundingRects (of: glyphs)
      var minX             = Float (0)
      var minY             = Float (0)
      var maxX             = Float (0)
      var maxY             = Float (0)
      
      self .glyphs [lineNumber] = glyphs

      for i in 0 ..< glyphs .count
      {
         let advance = advances [i]
         let rect    = rects [i]
         
         maxX += Float (advance .width)
         minY  = min (minY, Float (rect .minY))
         maxY  = max (maxY, Float (rect .maxY))
      }
      
      if glyphs .isEmpty
      {
         minY = 0
         maxY = 0
      }
      else
      {
         minX = Float (rects [0] .minX)
      }
      
      switch fontStyleNode .normalizedMajorAlignment
      {
         case .BEGIN, .FIRST:
            minX = 0
         default:
            break
      }

      return (Vector2f (minX, minY), Vector2f (maxX, maxY))
   }
   
   private final func vertical ()
   {
      guard let font = fontStyleNode .font else { return }
      
      let numLines    = textNode .string .count
      let maxExtent   = max (0, textNode .maxExtent)
      let leftToRight = fontStyleNode .leftToRight
      let spacing     = fontStyleNode .spacing
      let scale       = fontStyleNode .scale
      
      var bbox = Box2f ()
            
      // Calculate bboxes.

      let first = leftToRight ? 0 : numLines - 1
      let last  = leftToRight ? numLines : -1
      let step  = leftToRight ? 1 : -1
      var t     = 0

      for l in stride (from: first, to: last, by: step)
      {
         let attributedString = CFAttributedStringCreate (nil, textNode .string [l] as CFString, [kCTFontAttributeName : font] as CFDictionary)
         let glyphs           = attributedString! .glyphs ()
         
         for glyph in glyphs
         {
         }
      }
   }

   internal func build () { }
   
   // Rendering preparations
   
   internal func traverse (_ type : X3DTraverseType, _ renderer : X3DRenderer) { }
   
   internal func render (_ context : X3DRenderContext, _ renderEncoder : MTLRenderCommandEncoder) { }
}

fileprivate extension CFAttributedString
{
   func glyphs () -> [CGGlyph]
   {
      var glyphs    = [CGGlyph] ()
      let line      = self .line ()
      let glyphRuns = line .glyphRuns ()
      
      for glyphRun in glyphRuns
      {
         glyphs .append (contentsOf: glyphRun .glyphs ())
      }
      
      return glyphs
   }
}
