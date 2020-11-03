//
//  File.swift
//  
//
//  Created by Holger Seelig on 03.11.20.
//

internal final class X3DPolygonText :
   X3DTextGeometry
{
   private final var textNode      : Text
   private final var fontStyleNode : FontStyle

   internal init (textNode : Text, fontStyleNode : FontStyle)
   {
      self .textNode      = textNode
      self .fontStyleNode = fontStyleNode
      
      super .init (textNode: textNode, fontStyleNode: fontStyleNode)
   }
}
