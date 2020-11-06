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
   
   public final override class var typeName       : String { "ScreenFontStyle" }
   public final override class var component      : String { "Layout" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "fontStyle" }

   // Fields

   @SFFloat public final var pointSize : Float = 12

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
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
   
   internal final override func makeTextGeometry (textNode : Text) -> X3DScreenText?
   {
      return X3DScreenText (textNode: textNode, fontStyleNode: self)
   }
}
