//
//  JSSFNode.swift
//
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

@objc internal protocol SFNodeExports :
   JSExport
{
   typealias SFNode = JavaScript .SFNode

   init ()
   
   func equals (_ color : SFNode) -> JSValue
   func assign (_ color : SFNode)
   
   func getProperty (_ name : String) -> Any
   func setProperty (_ name : String, _ value : Any)
   
   func getNodeTypeName () -> String
   func getNodeName () -> String
   func getNodeType () -> [Int32]
   //func getFieldDefinitions () -> FieldDefinitionArray

   func toVRMLString () -> String
   func toXMLString () -> String
}

extension JavaScript
{
   @objc internal final class SFNode :
      X3DField,
      SFNodeExports
   {
      typealias Internal = X3D .SFNode <X3D .X3DNode>
      typealias Inner    = Internal .Value
      
      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFNode"] = Self .self
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 1
         {
            self .object = Internal ()
         }
         else
         {
            self .object = Internal ()
         }
         
         super .init (object)
      }
      
      internal init (object : Internal)
      {
         self .object = object
         
         super .init (object)
      }
      
      // Common operators
      
      public final func equals (_ node : SFNode) -> JSValue
      {
         return JSValue (bool: object .wrappedValue === node .object .wrappedValue, in: JSContext .current ())
      }
      
      public final func assign (_ node : SFNode)
      {
         object .wrappedValue = node .object .wrappedValue
      }
      
      // Properties
      
      public final func getProperty (_ name : String) -> Any
      {
         if let node = object .wrappedValue
         {
            return JavaScript .getValue (JSContext .current (), try! node .getField (name: name))
         }
         else
         {
            return JSValue (nullIn: JSContext .current ())!
         }
      }
      
      public final func setProperty (_ name : String, _ value : Any)
      {
         if let node = object .wrappedValue
         {
            JavaScript .setValue (try! node .getField (name: name), value)
         }
      }
      
      public final func getNodeTypeName () -> String
      {
         return object .wrappedValue? .getTypeName () ?? "X3DNode"
      }
      
      public final func getNodeName () -> String
      {
         return object .wrappedValue? .getName () ?? ""
      }
      
      public final func getNodeType () -> [Int32]
      {
         return object .wrappedValue? .getType () .map { $0 .rawValue } ?? [ ]
      }
      
      // public final func getFieldDefinitions () -> FieldDefinitionArray

      public final func toVRMLString () -> String
      {
         return object .wrappedValue? .toString () ?? ""
      }
      
      public final func toXMLString () -> String
      {
         return object .wrappedValue? .toString () ?? ""
      }
   }
}
