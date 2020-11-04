//
//  File.swift
//  
//
//  Created by Holger Seelig on 03.11.20.
//

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
      
      if fontStyleNode .horizontal
      {
         for line in glyphs
         {
            let advances = font .advances (of: line)
            
            for g in 0 ..< line .count
            {
               let glyph    = line [g]
               let advance  = advances [g]
               let geometry = glyphGeometry (font, glyph, primitiveQuality)
            }
         }
      }
      else
      {
         
      }
   }
   
   private final func glyphGeometry (_ font : CTFont, _ glyph : CGGlyph, _ primitiveQuality : String) -> [Vector2f]
   {
      let triangles = [Vector2f] ()
      let path      = font .path (for: glyph)
      
      debugPrint (path)
      
      return triangles
   }
}
