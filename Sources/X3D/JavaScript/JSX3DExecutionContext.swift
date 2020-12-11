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
   
   var specificationVersion : String { get }
   var encoding             : String { get }
   var profile              : JavaScript .ProfileInfo { get }
   var worldURL             : String { get }
   
   func getNamedNode (_ name : String) -> JSValue?
   
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
      
      dynamic public final var specificationVersion : String { executionContext .getSpecificationVersion () }
      dynamic public final var encoding             : String { executionContext .getEncoding () }
      dynamic public final var profile              : ProfileInfo { ProfileInfo (executionContext .getProfile ()) }
      dynamic public final var worldURL             : String { executionContext .getWorldURL () .absoluteURL .description }

      // Named node handling
      
      public final func getNamedNode (_ name : String) -> JSValue?
      {
         do
         {
            let node = try executionContext .getNamedNode (name: name)
            
            return SFNode .initWithProxy (JSContext .current (), field: X3D .SFNode (wrappedValue: node))
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
