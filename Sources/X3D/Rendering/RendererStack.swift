//
//  File.swift
//  
//
//  Created by Holger Seelig on 16.11.20.
//

internal final class RendererStack
{
   private final unowned let browser : X3DBrowser
   private final var renderers       : [X3DRenderer] = [ ]
   
   public init (for browser : X3DBrowser)
   {
      self .browser = browser
   }
   
   internal final func pop () -> X3DRenderer
   {
      if renderers .isEmpty
      {
         return X3DRenderer (for: browser)
      }
      else
      {
         return renderers .removeLast ()
      }
   }
   
   internal final func push (_ renderer : X3DRenderer)
   {
      renderers .append (renderer)
   }
}
