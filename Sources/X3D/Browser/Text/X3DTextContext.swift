//
//  File.swift
//  
//
//  Created by Holger Seelig on 03.11.20.
//

internal final class X3DTextContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate final var defaultFontStyleNode : FontStyle
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      self .defaultFontStyleNode = FontStyle (with: executionContext)

      super .init (executionContext .browser!, executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      defaultFontStyleNode .setup ()
   }
}

internal protocol X3DTextContext : AnyObject
{
   var browser               : X3DBrowser { get }
   var textContextProperties : X3DTextContextProperties! { get }
}

extension X3DTextContext
{
   internal var defaultFontStyleNode : FontStyle { textContextProperties .defaultFontStyleNode }
}
