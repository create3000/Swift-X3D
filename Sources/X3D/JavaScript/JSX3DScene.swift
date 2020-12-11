//
//  File.swift
//  
//
//  Created by Holger Seelig on 04.12.20.
//

import JavaScriptCore

@objc internal protocol X3DSceneExports :
   JSExport
{
   typealias SFNode = JavaScript .SFNode
   typealias MFNode = JavaScript .MFNode
   
   var rootNodes : MFNode { get set }
   
   func toString () -> String
}

extension JavaScript
{
   @objc internal final class X3DScene :
      X3DExecutionContext,
      X3DSceneExports
   {
      // Construction
      
      public final override class func register (_ context : JSContext)
      {
         context ["X3DScene"] = Self .self
         
         context .evaluateScript ("DefineProperty (this, \"X3DScene\", X3DScene);")
      }
      
      internal let scene : X3D .X3DScene
      
      internal init (_ scene : X3D .X3DScene)
      {
         self .scene = scene
         
         super .init (scene)
      }
      
      // Property access
      
      dynamic public override final var rootNodes : MFNode
      {
         get { MFNode (field: executionContext .$rootNodes) }
         set { executionContext .rootNodes = newValue .field .wrappedValue }
      }

      // Input/Output
      
      public final override func toString () -> String
      {
         return "[object X3DScene]"
      }
   }
}
