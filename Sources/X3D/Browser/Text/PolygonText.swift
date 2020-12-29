//
//  File.swift
//  
//
//  Created by Holger Seelig on 03.11.20.
//

import LibTessSwift

internal final class PolygonText :
   X3DTextGeometry
{
   // Member types
   
   private typealias GlyphCache  = [CGGlyph : [Vector3f]]
   private typealias GlyphCaches = [URL : GlyphCache]
   
   // Static properties
   
   static private var glyphCaches = GlyphCaches ()
   
   // Construction
   
   internal init (textNode : Text, fontStyleNode : FontStyle)
   {
      super .init (textNode: textNode, fontStyleNode: fontStyleNode)
   }
   
   // Build
   
   internal final override func build ()
   {
      super .build ()
      
      guard let font = fontStyleNode .font else { return }
      
      let primitiveQuality = fontStyleNode .browser! .browserOptions .PrimitiveQuality
      let dimension        = PolygonText .dimension (primitiveQuality)
      let scale            = Vector3f (repeating: fontStyleNode .scale)
      let spacing          = fontStyleNode .spacing
      let origin           = textNode .origin
      
      if fontStyleNode .horizontal
      {
         for l in 0 ..< glyphs .count
         {
            let line        = glyphs [l]
            let advances    = font .advances (of: line)
            let translation = translations [l]
            let charSpacing = charSpacings [l]
            var advance     = Float (0)

            for g in 0 ..< line .count
            {
               let glyph    = line [g]
               let geometry = glyphGeometry (font, glyph, dimension)
               let xOffset  = minorAlignment .x + translation .x + advance + Float (g) * charSpacing
               let yOffset  = minorAlignment .y + translation .y
               let offset   = Vector3f (xOffset, yOffset, 0)
               
               for point in geometry
               {
                  let p = simd_muladd (point, scale, offset)
                  let t = Vector4f ((p .x - origin .x) / spacing, (p .y - origin .y) / spacing, 0, 1)
                  
                  textNode .addPrimitive (fogDepth: 0,
                                          color: Vector4f .one,
                                          texCoords: [t],
                                          normal: Vector3f .zAxis,
                                          point: p)
               }
               
               advance += Float (advances [g] .width) * scale .x
            }
         }
      }
      else
      {
         var t = 0
         
         for line in glyphs
         {
            for glyph in line
            {
               let translation = translations [t]
               let geometry    = glyphGeometry (font, glyph, dimension)
               let offset      = Vector3f (minorAlignment + translation, 0)

               for point in geometry
               {
                  let p = simd_muladd (point, scale, offset)
                  let t = Vector4f ((p .x - origin .x) / spacing, (p .y - origin .y) / spacing, 0, 1)
                  
                  textNode .addPrimitive (fogDepth: 0,
                                          color: Vector4f .one,
                                          texCoords: [t],
                                          normal: Vector3f .zAxis,
                                          point: p)
               }
               
               t += 1
            }
         }
      }
   }
   
   private final func glyphGeometry (_ font : CTFont, _ glyph : CGGlyph, _ dimension : Int) -> [Vector3f]
   {
      // Try get cached geometry.
      if let geometry = PolygonText .glyphCaches [fontStyleNode .fileURL!]? [glyph]
      {
         return geometry
      }
      else
      {
         // Make glyph geometry.
         let geometry = makeGlyphGeometry (font, glyph, dimension)
         
         // Cache geometry.
         PolygonText .glyphCaches [fontStyleNode .fileURL!, default: GlyphCache ()] [glyph] = geometry
         
         return geometry
      }
   }
   
   private final func makeGlyphGeometry (_ font : CTFont, _ glyph : CGGlyph, _ dimension : Int) -> [Vector3f]
   {
      // Make contours.
      
      guard let tess = TessC () else { return [ ] }
      
      let path    = font .path (for: glyph)
      var contour = [Vector3f] ()
      var current = CGPoint ()

      path? .applyWithBlock
      {
         element in
         
         switch element .pointee .type
         {
            case .moveToPoint: do
            {
               current = element .pointee .points [0]
               
               contour .append (Vector3f (Float (current .x), Float (current .y), Float (0)))
            }
            case .addLineToPoint: do
            {
               current = element .pointee .points [0]
               
               contour .append (Vector3f (Float (current .x), Float (current .y), Float (0)))
            }
            case .addQuadCurveToPoint: do
            {
               let a = Vector2f (Float (current .x), Float (current .y))
               let b = Vector2f (Float (element .pointee .points [0] .x), Float (element .pointee .points [0] .y))
               let c = Vector2f (Float (element .pointee .points [1] .x), Float (element .pointee .points [1] .y))
               
               for i in 0 ..< dimension
               {
                  let t = Float (i) / Float (dimension - 1)
                  let p = quad_mix (a, b, c, t: t)
                  
                  contour .append (Vector3f (Float (p .x), Float (p .y), Float (0)))
               }
               
               current = element .pointee .points [1]
            }
            case .addCurveToPoint: do
            {
               let a = Vector2f (Float (current .x), Float (current .y))
               let b = Vector2f (Float (element .pointee .points [0] .x), Float (element .pointee .points [0] .y))
               let c = Vector2f (Float (element .pointee .points [1] .x), Float (element .pointee .points [1] .y))
               let d = Vector2f (Float (element .pointee .points [2] .x), Float (element .pointee .points [2] .y))

               for i in 0 ..< dimension
               {
                  let t = Float (i) / Float (dimension - 1)
                  let p = cubic_mix (a, b, c, d, t: t)
                  
                  contour .append (Vector3f (Float (p .x), Float (p .y), Float (0)))
               }
               
               current = element .pointee .points [2]
            }
            case .closeSubpath: do
            {
               guard !contour .isEmpty else { break }
               
               let ccw = dot (PolygonText .makePolygonNormal (for: contour), .zAxis) > 0
               
               // Add contour.
               tess .addContour (ccw ? contour : contour .reversed ())
               contour .removeAll (keepingCapacity: true)
            }
            @unknown default:
               break
         }
      }
      
      // Tesselate - if no errors are thrown, we're good!
      guard let (points, indices) = try? tess .tessellate (windingRule: .evenOdd, elementType: .polygons, polySize: 3) else
      {
         return [ ]
      }
      
      // Extract each index for each polygon triangle found.
      return indices .map { points [$0] }
   }
   
   static private func makePolygonNormal (for vertices : [Vector3f]) -> Vector3f
   {
      // Determine polygon normal.
      // We use Newell's method https://www.opengl.org/wiki/Calculating_a_Surface_Normal here:

      var normal  = Vector3f .zero
      var current = Vector3f .zero
      var next    = vertices [0]

      for i in 0 ..< vertices .count
      {
         swap (&current, &next)

         next = vertices [(i + 1) % vertices .count]

         normal .x += (current .y - next .y) * (current .z + next .z)
         normal .y += (current .z - next .z) * (current .x + next .x)
         normal .z += (current .x - next .x) * (current .y + next .y)
      }

      return normalize (normal)
   }
   
   static private func dimension (_ primitiveQuality : String) -> Int
   {
      switch primitiveQuality
      {
         case "LOW":  return 3
         case "HIGH": return 7
         default:     return 5
      }
   }
}
