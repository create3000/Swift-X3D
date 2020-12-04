//
//  File.swift
//  
//
//  Created by Holger Seelig on 04.12.20.
//

internal final class X3DScriptingContextProperties :
   X3DBaseNode
{
   // Properties
   
   @MFNode fileprivate final var scenes : [X3DScene?]
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addChildObjects ($scenes)
   }
}

internal protocol X3DScriptingContext : class
{
   var browser                    : X3DBrowser { get }
   var scriptingContextProperties : X3DScriptingContextProperties! { get }
}

extension X3DScriptingContext
{
   internal var scriptingScenes : [X3DScene?]
   {
      get { scriptingContextProperties .scenes }
      set { scriptingContextProperties .scenes = newValue }
   }
}