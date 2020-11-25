//
//  File.swift
//  
//
//  Created by Holger Seelig on 16.11.20.
//

internal final class RendererStack
{
   private final unowned let browser : X3DBrowser
   private final var renderers       : [Renderer] = [ ]
   
   public init (for browser : X3DBrowser)
   {
      self .browser = browser
   }
   
   internal final func pop () -> Renderer
   {
      if renderers .isEmpty
      {
         return Renderer (for: browser)
      }
      else
      {
         return renderers .removeLast ()
      }
   }
   
   internal final func push (_ renderer : Renderer)
   {
      renderers .append (renderer)
   }
}
