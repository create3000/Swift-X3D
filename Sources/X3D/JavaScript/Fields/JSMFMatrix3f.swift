//
//  JSMFMatrix3f.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFMatrix3fExports :
   JSExport
{
   typealias SFMatrix3f = JavaScript .SFMatrix3f
   typealias MFMatrix3f = JavaScript .MFMatrix3f
   typealias Context    = JavaScript .Context

   init ()
   
   func equals (_ array : MFMatrix3f) -> JSValue
   func assign (_ array : MFMatrix3f)

   func get1Value (_ context : Context, _ index : Int) -> SFMatrix3f
   func set1Value (_ index : Int, _ value : SFMatrix3f)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFMatrix3f :
      X3DArrayField,
      MFMatrix3fExports
   {
      typealias Internal = X3D .MFMatrix3f

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFMatrix3f"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, context, targets, \"MFMatrix3f\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFMatrix3f .self) as? SFMatrix3f)? .object .wrappedValue ?? .identity
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
         return proxy .construct (withArguments: [MFMatrix3f (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFMatrix3f) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFMatrix3f)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ context : Context, _ index : Int) -> SFMatrix3f
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: .identity)
         }

         return SFMatrix3f (object: SFMatrix3fReference (object, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFMatrix3f)
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
   internal final class SFMatrix3fReference :
      X3D .SFMatrix3f
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFMatrix3f
      private final let index : Int

      internal init (_ array : X3D .MFMatrix3f, _ index : Int)
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
