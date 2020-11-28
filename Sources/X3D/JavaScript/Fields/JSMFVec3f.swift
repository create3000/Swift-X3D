//
//  JSMFVec3f.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFVec3fExports :
   JSExport
{
   typealias SFVec3f = JavaScript .SFVec3f
   typealias MFVec3f = JavaScript .MFVec3f
   
   init ()
   
   func equals (_ array : MFVec3f) -> JSValue
   func assign (_ array : MFVec3f)

   func get1Value (_ index : Int) -> SFVec3f
   func set1Value (_ index : Int, _ value : SFVec3f)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFVec3f :
      X3DArrayField,
      MFVec3fExports
   {
      typealias Internal = X3D .MFVec3f

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFVec3f"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, \"MFVec3f\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map { ($0 .toObjectOf (SFVec3f .self) as? SFVec3f)? .object .wrappedValue ?? .zero })
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
         return proxy .construct (withArguments: [MFVec3f (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFVec3f) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFVec3f)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFVec3f
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: .zero)
         }

         return SFVec3f (object: SFVec3fReference (object, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFVec3f)
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: .zero)
         }
         
         object .wrappedValue [index] = value .object .wrappedValue
      }
      
      // Properties
      
      dynamic public final var length : Int
      {
         get { object .wrappedValue .count }
         set { object .wrappedValue .resize (newValue, fillWith: .zero) }
      }
   }
}

extension JavaScript
{
   internal final class SFVec3fReference :
      X3D .SFVec3f
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFVec3f
      private final let index : Int

      internal init (_ array : X3D .MFVec3f, _ index : Int)
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
            array .wrappedValue .resize (index + 1, fillWith: .zero)
         }
      }
   }
}
