//
//  JSMFRotation.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFRotationExports :
   JSExport
{
   typealias SFRotation = JavaScript .SFRotation
   typealias MFRotation = JavaScript .MFRotation
   
   init ()
   
   func equals (_ array : MFRotation) -> JSValue
   func assign (_ array : MFRotation)

   func get1Value (_ index : Int) -> SFRotation
   func set1Value (_ index : Int, _ value : SFRotation)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFRotation :
      X3DArrayField,
      MFRotationExports
   {
      typealias Internal = X3D .MFRotation

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFRotation"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, \"MFRotation\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFRotation .self) as? SFRotation)? .object .wrappedValue ?? .identity
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
         return proxy .construct (withArguments: [MFRotation (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFRotation) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFRotation)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFRotation
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: .identity)
         }

         return SFRotation (object: SFRotationReference (object, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFRotation)
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
   internal final class SFRotationReference :
      X3D .SFRotation
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFRotation
      private final let index : Int

      internal init (_ array : X3D .MFRotation, _ index : Int)
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
