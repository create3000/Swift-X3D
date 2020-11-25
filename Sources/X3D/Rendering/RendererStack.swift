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
   private final let queue           : DispatchQueue = DispatchQueue (label: "create3000.renderer-stack")

   public init (for browser : X3DBrowser)
   {
      self .browser = browser
   }
   
   internal final func pop () -> Renderer
   {
      if queue .sync (execute: { renderers .isEmpty })
      {
         return Renderer (for: browser)
      }
      else
      {
         return queue .sync { renderers .removeLast () }
      }
   }
   
   internal final func push (_ renderer : Renderer)
   {
      queue .sync { renderers .append (renderer) }
   }
}
