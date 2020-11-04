//
//  File.swift
//  
//
//  Created by Holger Seelig on 03.11.20.
//

import LibTessSwift

internal final class X3DPolygonText :
   X3DTextGeometry
{
   internal init (textNode : Text, fontStyleNode : FontStyle)
   {
      super .init (textNode: textNode, fontStyleNode: fontStyleNode)
   }
   
   internal final override func build ()
   {
      guard let font = fontStyleNode .font else { return }
      
      let primitiveQuality = fontStyleNode .browser! .browserOptions .PrimitiveQuality
      let dimension        = X3DPolygonText .dimension (primitiveQuality)
      let scale            = fontStyleNode .scale
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
               
               for point in geometry
               {
                  let x = point .x * scale + xOffset
                  let y = point .y * scale + yOffset
                  
                  textNode .addPrimitive (fogDepth: 0,
                                          color: Vector4f .one,
                                          texCoords: [Vector4f ((x - origin .x) / spacing, (y - origin .y) / spacing, 0, 1)],
                                          normal: Vector3f .zAxis,
                                          point: Vector3f (x, y, 0))
               }
               
               advance += Float (advances [g] .width) * scale
            }
         }
      }
      else
      {
         
      }
   }
   
   private final func glyphGeometry (_ font : CTFont, _ glyph : CGGlyph, _ dimension : Int) -> [Vector3f]
   {
      // Make contours.
      
      let path      = font .path (for: glyph)
      var contours  = [[Vector3f]] ()
      var contour   = [Vector3f] ()
      var current   = CGPoint ()
      
      debugPrint (path)

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
            }
            case .closeSubpath: do
            {
               contours .append (contour .reversed ())
               contour .removeAll (keepingCapacity: true)
            }
            @unknown default:
               break
         }
      }
      
      // Tessellate contours.
      
      guard let tess = TessC () else { return [ ] }
      
      for contour in contours
      {
         // Add the contour to LibTess.
         tess .addContour (contour)
      }

      // Tesselate - if no errors are thrown, we're good!
      guard let (points, indices) = try? tess .tessellate (windingRule: .evenOdd, elementType: .polygons, polySize: 3) else
      {
         return [ ]
      }
      
      // Extract each index for each polygon triangle found.
      return indices .map { points [$0] }
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

internal func quad_mix (_ a : Vector2f, _ b : Vector2f, _ c : Vector2f, t : Float) -> Vector2f
{
   let q0 = mix (a, b, t: t)
   let q1 = mix (b, c, t: t)
   let r  = mix (q0, q1, t: t)
   
   return r
}
