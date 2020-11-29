//
//  JSMFVec2f.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFVec2fExports :
   JSExport
{
   typealias SFVec2f = JavaScript .SFVec2f
   typealias MFVec2f = JavaScript .MFVec2f
   
   init ()
   
   func equals (_ array : MFVec2f) -> JSValue
   func assign (_ array : MFVec2f)

   func get1Value (_ index : Int) -> SFVec2f
   func set1Value (_ index : Int, _ value : SFVec2f)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFVec2f :
      X3DArrayField,
      MFVec2fExports
   {
      typealias Internal = X3D .MFVec2f

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFVec2f"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, targets, \"MFVec2f\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFVec2f .self) as? SFVec2f)? .object .wrappedValue ?? .zero
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
         return proxy .construct (withArguments: [MFVec2f (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFVec2f) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFVec2f)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFVec2f
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: .zero)
         }

         return SFVec2f (object: SFVec2fReference (object, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFVec2f)
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
   internal final class SFVec2fReference :
      X3D .SFVec2f
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFVec2f
      private final let index : Int

      internal init (_ array : X3D .MFVec2f, _ index : Int)
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
