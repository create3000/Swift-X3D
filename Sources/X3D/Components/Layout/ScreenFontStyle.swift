//
//  ScreenFontStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Cocoa

fileprivate let scaleFactor : Float = 4/3

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
   
   internal final override var scale : Float
   {
      return pointSize * Float (NSScreen .main! .unitsPerInch .height) / 72 * scaleFactor
   }
   
   internal final override func makeTextGeometry (textNode : Text) -> ScreenText?
   {
      return ScreenText (textNode: textNode, fontStyleNode: self)
   }
}

public extension NSScreen
{
   var unitsPerInch : CGSize
   {
      let millimetersPerInch : CGFloat = 25.4
      let screenDescription            = deviceDescription
      
      if let displayUnitSize = (screenDescription [NSDeviceDescriptionKey .size] as? NSValue)? .sizeValue,
         let screenNumber    = (screenDescription [NSDeviceDescriptionKey ("NSScreenNumber")] as? NSNumber)? .uint32Value
      {
         let displayPhysicalSize = CGDisplayScreenSize (screenNumber)

         return CGSize (width:  millimetersPerInch * displayUnitSize .width  / displayPhysicalSize .width,
                        height: millimetersPerInch * displayUnitSize .height / displayPhysicalSize .height)
      }
      else
      {
         // This is the same as what CoreGraphics assumes if no EDID data is available from the display device — https://developer.apple.com/documentation/coregraphics/1456599-cgdisplayscreensize?language=objc
         return CGSize (width: 72, height: 72)
      }
   }
}
