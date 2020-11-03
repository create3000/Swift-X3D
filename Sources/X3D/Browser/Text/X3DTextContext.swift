//
//  File.swift
//  
//
//  Created by Holger Seelig on 03.11.20.
//

public final class X3DTextContextProperies :
   X3DBaseNode
{
   // Properties
   
   @SFNode fileprivate final var defaultFontStyleNode : FontStyle?
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addChildObjects ($defaultFontStyleNode)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      defaultFontStyleNode = FontStyle (with: executionContext!)

      defaultFontStyleNode! .setup ()
   }
}

public protocol X3DTextContext : class
{
   var browser               : X3DBrowser { get }
   var textContextProperties : X3DTextContextProperies! { get }
}

extension X3DTextContext
{
   internal var defaultFontStyleNode : FontStyle { textContextProperties .defaultFontStyleNode! }
}
