//
//  File.swift
//  
//
//  Created by Holger Seelig on 06.11.20.
//

internal final class ScreenText :
   X3DTextGeometry
{
   // Construction
   
   internal init (textNode : Text, fontStyleNode : ScreenFontStyle)
   {
      super .init (textNode: textNode, fontStyleNode: fontStyleNode)
   }
   
   // Build
   
   internal final override func build ()
   {
      super .build ()
      
      guard let font = fontStyleNode .font else { return }
      
      if fontStyleNode .horizontal
      {
         
      }
      else
      {
         
      }
   }
}
