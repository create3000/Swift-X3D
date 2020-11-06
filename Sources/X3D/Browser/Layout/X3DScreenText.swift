//
//  File.swift
//  
//
//  Created by Holger Seelig on 06.11.20.
//

internal final class X3DScreenText :
   X3DTextGeometry
{
   // Construction
   
   internal init (textNode : Text, fontStyleNode : ScreenFontStyle)
   {
      super .init (textNode: textNode, fontStyleNode: fontStyleNode)
   }
}
