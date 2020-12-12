//
//  File.swift
//  
//
//  Created by Holger Seelig on 11.12.20.
//

import JavaScriptCore

@objc internal protocol X3DExternProtoDeclarationExports :
   JSExport
{
   typealias X3DFieldDefinition = JavaScript .X3DFieldDefinition
   
   var name          : String { get }
   var fields        : [X3DFieldDefinition] { get }
   var url           : [String] { get }
   var isExternProto : Bool { get }
   var loadState     : Int32 { get }
   
   func toString () -> String
}

extension JavaScript
{
   @objc internal final class X3DExternProtoDeclaration :
      NSObject,
      X3DExternProtoDeclarationExports
   {
      // Construction
      
      public final class func register (_ context : JSContext)
      {
         context ["X3DExternProtoDeclaration"] = Self .self
         
         context .evaluateScript ("DefineProperty (this, \"X3DExternProtoDeclaration\", X3DExternProtoDeclaration);")
      }
      
      internal let externproto : X3D .X3DExternProtoDeclaration
      
      internal init (_ externproto : X3D .X3DExternProtoDeclaration)
      {
         self .externproto = externproto
      }
      
      // Property access
      
      dynamic public final var name : String { externproto .getName () }
      
      dynamic public final var fields : [X3DFieldDefinition]
      {
         var fieldDefinitions = [X3DFieldDefinition] ()
         
         for field in externproto .getUserDefinedFields ()
         {
            fieldDefinitions .append (X3DFieldDefinition (accessType: field .getAccessType () .rawValue, dataType: field .getType () .rawValue, name: field .getName ()))
         }
         
         return fieldDefinitions
      }
      
      dynamic public final var url : [String] { externproto .url .map { $0 } }
      
      dynamic public final var isExternProto : Bool { externproto .isExternProto }
      
      dynamic public final var loadState : Int32 { Int32 (externproto .loadState .rawValue) }
      
      // Input/Output
      
      public final func toString () -> String
      {
         return "[object X3DExternProtoDeclaration]"
      }
   }
}
