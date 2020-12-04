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
   typealias SFNode = JavaScript .SFNode
   
   var worldURL : String { get }
   
   func getNamedNode (_ name : String) -> Any?
   
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
         context ["X3DExecutionContext"] = Self .self
         
         context .evaluateScript ("DefineProperty (this, \"X3DExecutionContext\", X3DExecutionContext);")
      }
      
      internal let executionContext : X3D .X3DExecutionContext
      
      internal init (_ executionContext : X3D .X3DExecutionContext)
      {
         self .executionContext = executionContext
      }
      
      //
      
      dynamic public final var worldURL : String { executionContext .getWorldURL () .absoluteURL .description }
      
      // Named node handling
      
      public final func getNamedNode (_ name : String) -> Any?
      {
         do
         {
            let node = try executionContext .getNamedNode (name: name)
            
            return getValue (JSContext .current (), JSContext .current () .browser!, X3D .SFNode (wrappedValue: node))
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      // Input/Output
      
      public func toString () -> String
      {
         return "[object X3DExecutionContext]"
      }
   }
}
