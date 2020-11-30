//
//  File.swift
//  
//
//  Created by Holger Seelig on 29.11.20.
//

import JavaScriptCore

@objc internal protocol X3DFieldDefinitionExports :
   JSExport
{
   var accessType  : Int32 { get }
   var dataType    : Int32 { get }
   var name        : String { get }
   
   func toString () -> String
}

extension JavaScript
{
   @objc internal final class X3DFieldDefinition :
      NSObject,
      X3DFieldDefinitionExports
   {
      // Properties
      
      dynamic public final let accessType : Int32
      dynamic public final let dataType   : Int32
      dynamic public final let name       : String
      
      // Construction
      
      public static func register (_ context : JSContext)
      {
         context ["X3DFieldDefinition"] = Self .self
      }
      
      internal init (accessType : Int32, dataType : Int32, name : String)
      {
         self .accessType = accessType
         self .dataType   = dataType
         self .name       = name
      }
      
      // Input/Output
      
      public final func toString () -> String
      {
         return "[object X3DFieldDefinition]"
      }
   }
}
