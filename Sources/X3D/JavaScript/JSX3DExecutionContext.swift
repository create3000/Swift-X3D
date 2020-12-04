//
//  File.swift
//  
//
//  Created by Holger Seelig on 04.12.20.
//

import JavaScriptCore

@objc internal protocol X3DExecutionContextExports :
   JSExport
{
   func toString () -> String
}

extension JavaScript
{
   @objc internal class X3DExecutionContext :
      NSObject,
      X3DExecutionContextExports
   {
      // Construction
      
      public class func register (_ context : JSContext)
      {
         context ["X3DScene"] = Self .self
         
         context .evaluateScript ("DefineProperty (this, \"X3DExecutionContext\", X3DExecutionContext);")
      }
      
      internal let executionContext : X3D .X3DExecutionContext
      
      internal init (_ executionContext : X3D .X3DExecutionContext)
      {
         self .executionContext = executionContext
      }

      // Input/Output
      
      public func toString () -> String
      {
         return "[object X3DExecutionContext]"
      }
   }
}
