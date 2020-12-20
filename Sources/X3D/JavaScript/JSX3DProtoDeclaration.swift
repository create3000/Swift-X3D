//
//  File.swift
//  
//
//  Created by Holger Seelig on 11.12.20.
//

import JavaScriptCore

@objc internal protocol X3DProtoDeclarationExports :
   JSExport
{
   typealias X3DFieldDefinition = JavaScript .X3DFieldDefinition
   
   var name          : String { get }
   var fields        : [X3DFieldDefinition] { get }
   var isExternProto : Bool { get }
   
   func newInstance () -> JSValue

   func toString () -> String
}

extension JavaScript
{
   @objc internal final class X3DProtoDeclaration :
      NSObject,
      X3DProtoDeclarationExports
   {
      // Construction
      
      public final class func register (_ context : JSContext)
      {
         context ["X3DProtoDeclaration"] = Self .self
         
         context .evaluateScript ("DefineProperty (this, \"X3DProtoDeclaration\", X3DProtoDeclaration);")
      }
      
      internal let proto : X3D .X3DProtoDeclaration
      
      internal init (_ proto : X3D .X3DProtoDeclaration)
      {
         self .proto = proto
      }
      
      // Property access
      
      dynamic public final var name : String { proto .getName () }
      
      dynamic public final var fields : [X3DFieldDefinition]
      {
         var fieldDefinitions = [X3DFieldDefinition] ()
         
         for field in proto .getUserDefinedFields ()
         {
            fieldDefinitions .append (X3DFieldDefinition (accessType: field .getAccessType () .rawValue, dataType: field .getType () .rawValue, name: field .getName ()))
         }
         
         return fieldDefinitions
      }
      
      dynamic public final var isExternProto : Bool { proto .isExternProto }
      
      public final func newInstance () -> JSValue
      {
         let node = proto .createInstance (with: proto .executionContext!)
         
         return SFNode .initWithProxy (JSContext .current (), field: X3D .SFNode (wrappedValue: node))
      }

      // Input/Output
      
      public final func toString () -> String
      {
         return "[object X3DProtoDeclaration]"
      }
   }
}
