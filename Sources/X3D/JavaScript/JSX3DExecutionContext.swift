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
   typealias SFNode                    = JavaScript .SFNode
   typealias MFNode                    = JavaScript .MFNode
   typealias ProfileInfo               = JavaScript .ProfileInfo
   typealias X3DProtoDeclaration       = JavaScript .X3DProtoDeclaration
   typealias X3DExternProtoDeclaration = JavaScript .X3DExternProtoDeclaration

   var specificationVersion : String { get }
   var encoding             : String { get }
   var profile              : ProfileInfo { get }
   var worldURL             : String { get }
   var rootNodes            : MFNode { get }
   var protos               : [X3DProtoDeclaration] { get }
   var externprotos         : [X3DExternProtoDeclaration] { get }

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
      
      // Property access 
      
      dynamic public final var specificationVersion : String { executionContext .getSpecificationVersion () }
      dynamic public final var encoding             : String { executionContext .getEncoding () }
      dynamic public final var profile              : ProfileInfo { ProfileInfo (executionContext .getProfile ()) }
      dynamic public final var worldURL             : String { executionContext .getWorldURL () .absoluteURL .description }
      
      dynamic public var rootNodes : MFNode
      {
         MFNode (field: executionContext .$rootNodes)
      }
      
      dynamic final public var protos : [X3DProtoDeclaration]
      {
         executionContext .getProtoDeclarations () .map { X3DProtoDeclaration ($0) }
      }
      
      dynamic final public var externprotos : [X3DExternProtoDeclaration]
      {
         executionContext .getExternProtoDeclarations () .map { X3DExternProtoDeclaration ($0) }
      }

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
