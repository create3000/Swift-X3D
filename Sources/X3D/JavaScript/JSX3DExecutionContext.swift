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
   var rootNodes            : JSValue { get }
   var protos               : [X3DProtoDeclaration] { get }
   var externprotos         : [X3DExternProtoDeclaration] { get }
   var routes               : [X3DRoute] { get }

   func createNode (_ typeName : String) -> JSValue?
   func createProto (_ typeName : String) -> JSValue?
   
   func getNamedNode (_ name : String) -> JSValue?
   func updateNamedNode (_ name : String, _ node : SFNode?)
   func removeNamedNode (_ name : String)
   
   func getImportedNode (_ importedName : String) -> JSValue?
   func updateImportedNode (_ inlineNode : SFNode?, _ exportedName : String, _ importedName : String?)
   func removeImportedNode (_ importedName : String)

   func addRoute (_ fromNode : SFNode?, _ fromReadableField : String, _ toNode : SFNode?, _ toWritableField : String) -> X3DRoute?
   func deleteRoute (_ route : X3DRoute?)

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
         
         context .evaluateScript ("""
(function (targets)
{
   const updateNamedNode    = X3DExecutionContext .prototype .updateNamedNode;
   const updateImportedNode = X3DExecutionContext .prototype .updateImportedNode;
   const addRoute           = X3DExecutionContext .prototype .addRoute;

   X3DExecutionContext .prototype .updateNamedNode = function (name, node)
   {
      return updateNamedNode .call (this, name, targets .get (node));
   };

   X3DExecutionContext .prototype .updateImportedNode = function (inlineNode, exportedName, importedName)
   {
      return updateImportedNode .call (this, targets .get (inlineNode), exportedName, importedName);
   };

   X3DExecutionContext .prototype .addRoute = function (fromNode, fromReadableField, toNode, toWritableField)
   {
      return addRoute .call (this, targets .get (fromNode), fromReadableField, targets .get (toNode), toWritableField);
   };
})
(targets);

DefineProperty (this, \"X3DExecutionContext\", X3DExecutionContext);
""")
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
      
      dynamic public var rootNodes : JSValue
      {
         MFNode .initWithProxy (JSContext .current (), field: X3D .MFNode (wrappedValue: executionContext .rootNodes))!
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
      
      public final func updateNamedNode (_ name : String, _ node : SFNode?)
      {
         do
         {
            guard let node = node? .field .wrappedValue else
            {
               return exception ("Node is null.")
            }
            
            try executionContext .updateNamedNode (name: name, node: node)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func removeNamedNode (_ name : String)
      {
         executionContext .removeNamedNode (name: name)
      }
      
      // Imported node handling
      
      public final func getImportedNode (_ importedName : String) -> JSValue?
      {
         do
         {
            let node = try executionContext .getImportedNode (importedName: importedName)
            
            return SFNode .initWithProxy (JSContext .current (), field: X3D .SFNode (wrappedValue: node))
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func updateImportedNode (_ inlineNode : SFNode?, _ exportedName : String, _ importedName : String?)
      {
         do
         {
            guard let inlineNode = inlineNode? .field .wrappedValue as? X3D .Inline else
            {
               return exception ("Node is not an Inline node.")
            }
            
            try executionContext .updateImportedNode (inlineNode: inlineNode, exportedName: exportedName, importedName: importedName ?? exportedName)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func removeImportedNode (_ importedName : String)
      {
         executionContext .removeImportedNode (importedName: importedName)
      }
      
      // Route handling
      
      public final func addRoute (_ fromNode : SFNode?,
                                  _ fromReadableField : String,
                                  _ toNode : SFNode?,
                                  _ toWritableField : String) -> X3DRoute?
      {
         do
         {
            guard let fromNode = fromNode? .field .wrappedValue else { return exception ("FromNode is not an SFNode.") }
            guard let toNode   = toNode?   .field .wrappedValue else { return exception ("ToNode is not an SFNode.") }
            
            let route = try executionContext .addRoute (sourceNode: fromNode,
                                                        sourceField: fromReadableField,
                                                        destinationNode: toNode,
                                                        destinationField: toWritableField)
            
            return X3DRoute (route)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func deleteRoute (_ route : X3DRoute?)
      {
         guard let route = route else { return exception ("Argument is not an X3DRoute.") }

         executionContext .deleteRoute (route: route .route)
      }

      // Input/Output
      
      public func toString () -> String
      {
         return "[object X3DExecutionContext]"
      }
   }
}
