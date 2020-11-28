//
//  JSMFMatrix4d.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFMatrix4dExports :
   JSExport
{
   typealias SFMatrix4d = JavaScript .SFMatrix4d
   typealias MFMatrix4d = JavaScript .MFMatrix4d
   
   init ()
   
   func equals (_ array : MFMatrix4d) -> JSValue
   func assign (_ array : MFMatrix4d)

   func get1Value (_ index : Int) -> SFMatrix4d
   func set1Value (_ index : Int, _ value : SFMatrix4d)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFMatrix4d :
      X3DArrayField,
      MFMatrix4dExports
   {
      typealias Internal = X3D .MFMatrix4d

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFMatrix4d"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, \"MFMatrix4d\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFMatrix4d .self) as? SFMatrix4d)? .object .wrappedValue ?? .identity
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
         return proxy .construct (withArguments: [MFMatrix4d (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFMatrix4d) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFMatrix4d)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFMatrix4d
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: .identity)
         }

         return SFMatrix4d (object: SFMatrix4dReference (object, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFMatrix4d)
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: .identity)
         }
         
         object .wrappedValue [index] = value .object .wrappedValue
      }
      
      // Properties
      
      dynamic public final var length : Int
      {
         get { object .wrappedValue .count }
         set { object .wrappedValue .resize (newValue, fillWith: .identity) }
      }
   }
}

extension JavaScript
{
   internal final class SFMatrix4dReference :
      X3D .SFMatrix4d
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFMatrix4d
      private final let index : Int

      internal init (_ array : X3D .MFMatrix4d, _ index : Int)
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
            array .wrappedValue .resize (index + 1, fillWith: .identity)
         }
      }
   }
}
