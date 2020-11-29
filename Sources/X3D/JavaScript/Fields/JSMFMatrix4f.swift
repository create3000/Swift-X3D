//
//  JSMFMatrix4f.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFMatrix4fExports :
   JSExport
{
   typealias SFMatrix4f = JavaScript .SFMatrix4f
   typealias MFMatrix4f = JavaScript .MFMatrix4f
   
   init ()
   
   func equals (_ array : MFMatrix4f) -> JSValue
   func assign (_ array : MFMatrix4f)

   func get1Value (_ index : Int) -> SFMatrix4f
   func set1Value (_ index : Int, _ value : SFMatrix4f)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFMatrix4f :
      X3DArrayField,
      MFMatrix4fExports
   {
      typealias Internal = X3D .MFMatrix4f

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFMatrix4f"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, targets, \"MFMatrix4f\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFMatrix4f .self) as? SFMatrix4f)? .object .wrappedValue ?? .identity
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
         return proxy .construct (withArguments: [MFMatrix4f (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFMatrix4f) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFMatrix4f)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFMatrix4f
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: .identity)
         }

         return SFMatrix4f (object: SFMatrix4fReference (object, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFMatrix4f)
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
   internal final class SFMatrix4fReference :
      X3D .SFMatrix4f
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFMatrix4f
      private final let index : Int

      internal init (_ array : X3D .MFMatrix4f, _ index : Int)
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
