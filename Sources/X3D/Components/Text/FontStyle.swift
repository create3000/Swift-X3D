//
//  FontStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class FontStyle :
   X3DFontStyleNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "FontStyle" }
   internal final override class var component      : String { "Text" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFFloat public final var size : Float = 1

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.FontStyle)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.initializeOnly, "language",    $language)
      addField (.initializeOnly, "family",      $family)
      addField (.initializeOnly, "style",       $style)
      addField (.initializeOnly, "size",        $size)
      addField (.initializeOnly, "spacing",     $spacing)
      addField (.initializeOnly, "horizontal",  $horizontal)
      addField (.initializeOnly, "leftToRight", $leftToRight)
      addField (.initializeOnly, "topToBottom", $topToBottom)
      addField (.initializeOnly, "justify",     $justify)

      $size .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> FontStyle
   {
      return FontStyle (with: executionContext)
   }
   
   // Property access
   
   internal final override var scale : Float { size }
   
   internal final override func makeTextGeometry (textNode : Text) -> PolygonText?
   {
      return PolygonText (textNode: textNode, fontStyleNode: self)
   }
}
