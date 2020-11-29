//
//  JSMFVec2d.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFVec2dExports :
   JSExport
{
   typealias SFVec2d = JavaScript .SFVec2d
   typealias MFVec2d = JavaScript .MFVec2d
   typealias Context = JavaScript .Context

   init ()
   
   func equals (_ array : MFVec2d) -> JSValue
   func assign (_ array : MFVec2d)

   func get1Value (_ context : Context, _ index : Int) -> SFVec2d
   func set1Value (_ index : Int, _ value : SFVec2d)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFVec2d :
      X3DArrayField,
      MFVec2dExports
   {
      typealias Internal = X3D .MFVec2d

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFVec2d"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, context, targets, \"MFVec2d\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFVec2d .self) as? SFVec2d)? .object .wrappedValue ?? .zero
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
         return proxy .construct (withArguments: [MFVec2d (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFVec2d) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFVec2d)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ context : Context, _ index : Int) -> SFVec2d
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: .zero)
         }

         return SFVec2d (object: SFVec2dReference (object, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFVec2d)
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
   internal final class SFVec2dReference :
      X3D .SFVec2d
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFVec2d
      private final let index : Int

      internal init (_ array : X3D .MFVec2d, _ index : Int)
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
