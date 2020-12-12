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
   typealias ComponentInfo             = JavaScript .ComponentInfo
   typealias X3DProtoDeclaration       = JavaScript .X3DProtoDeclaration
   typealias X3DExternProtoDeclaration = JavaScript .X3DExternProtoDeclaration
   typealias X3DRoute                  = JavaScript .X3DRoute

   var specificationVersion : String { get }
   var encoding             : String { get }
   var profile              : ProfileInfo { get }
   var components           : [ComponentInfo] { get }
   var worldURL             : String { get }
   var rootNodes            : MFNode { get }
   var protos               : [X3DProtoDeclaration] { get }
   var externprotos         : [X3DExternProtoDeclaration] { get }
   var routes               : [X3DRoute] { get }

   func createNode (_ typeName : String) -> JSValue?
   func createProto (_ typeName : String) -> JSValue?
   
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
      dynamic public final var components           : [ComponentInfo] { executionContext .getComponents () .map { ComponentInfo ($0) } }
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
      
      dynamic final public var routes : [X3DRoute]
      {
         executionContext .getRoutes () .map { X3DRoute ($0) }
      }
      
      // Node creation
      
      public final func createNode (_ typeName : String) -> JSValue?
      {
         do
         {
            return SFNode .initWithProxy (JSContext .current (), field: X3D .SFNode (wrappedValue: try executionContext .createNode (typeName: typeName)))
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func createProto (_ typeName : String) -> JSValue?
      {
         do
         {
            return SFNode .initWithProxy (JSContext .current (), field: X3D .SFNode (wrappedValue: try executionContext .createProto (typeName: typeName)))
         }
         catch
         {
            return exception (error .localizedDescription)
         }
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
