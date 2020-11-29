//
//  JSMFNode.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFNodeExports :
   JSExport
{
   typealias SFNode = JavaScript .SFNode
   typealias MFNode = JavaScript .MFNode
   
   init ()
   
   func equals (_ array : MFNode) -> JSValue
   func assign (_ array : MFNode)

   func get1Value (_ index : Int) -> JSValue
   func set1Value (_ index : Int, _ value : SFNode?)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFNode :
      X3DArrayField,
      MFNodeExports
   {
      typealias Internal = X3D .MFNode <X3D .X3DNode>

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFNode"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, targets, \"MFNode\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFNode .self) as? SFNode)? .object .wrappedValue
            })
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
      
      internal static func initWithProxy (object : Internal) -> JSValue!
      {
         return proxy .construct (withArguments: [MFNode (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFNode) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFNode)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> JSValue
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: nil)
         }
         
         if object .wrappedValue [index] == nil
         {
            return JSValue (nullIn: JSContext .current ())
         }
         else
         {
            return JSValue (object: SFNode (object: SFNodeReference (object, index)), in: JSContext .current ())
         }
      }
      
      public final func set1Value (_ index : Int, _ value : SFNode?)
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: nil)
         }

         object .wrappedValue [index] = value? .object .wrappedValue
      }
      
      // Properties
      
      dynamic public final var length : Int
      {
         get { object .wrappedValue .count }
         set { object .wrappedValue .resize (newValue, fillWith: nil) }
      }
   }
}

extension JavaScript
{
   internal final class SFNodeReference :
      X3D .SFNode <X3D .X3DNode>
   {
      public final override var wrappedValue : Value!
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFNode <X3D .X3DNode>
      private final let index : Int

      internal init (_ array : X3D .MFNode <X3D .X3DNode>, _ index : Int)
      {
         self .array = array
         self .index = index
         
         super .init ()
      }
      
      required public init ()
      {
         fatalError ("init() has not been implemented")
      }
      
      private final func resizeIfNeeded ()
      {
         if index >= array .wrappedValue .count
         {
            array .wrappedValue .resize (index + 1, fillWith: nil)
         }
      }
   }
}