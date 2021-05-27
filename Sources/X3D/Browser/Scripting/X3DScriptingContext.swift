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
   
   fileprivate final var scenes : [X3DScene] = [ ]
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
}

internal protocol X3DScriptingContext : AnyObject
{
   var browser                    : X3DBrowser { get }
   var scriptingContextProperties : X3DScriptingContextProperties! { get }
}

extension X3DScriptingContext
{
   internal var scriptingScenes : [X3DScene]
   {
      get { scriptingContextProperties .scenes }
      set { scriptingContextProperties .scenes = newValue }
   }
}
