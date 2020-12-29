//
//  ScreenFontStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ScreenFontStyle :
   X3DFontStyleNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ScreenFontStyle" }
   internal final override class var component      : String { "Layout" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "fontStyle" }

   // Fields

   @SFFloat public final var pointSize : Float = 12

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ScreenFontStyle)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.initializeOnly, "language",    $language)
      addField (.initializeOnly, "family",      $family)
      addField (.initializeOnly, "style",       $style)
      addField (.initializeOnly, "pointSize",   $pointSize)
      addField (.initializeOnly, "spacing",     $spacing)
      addField (.initializeOnly, "horizontal",  $horizontal)
      addField (.initializeOnly, "leftToRight", $leftToRight)
      addField (.initializeOnly, "topToBottom", $topToBottom)
      addField (.initializeOnly, "justify",     $justify)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ScreenFontStyle
   {
      return ScreenFontStyle (with: executionContext)
   }
   
   // Property access
   
   internal final override var scale : Float { 1 }
   
   internal final override func makeTextGeometry (textNode : Text) -> ScreenText?
   {
      return ScreenText (textNode: textNode, fontStyleNode: self)
   }
}
