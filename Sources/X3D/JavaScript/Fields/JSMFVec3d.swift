//
//  JSMFVec3d.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFVec3dExports :
   JSExport
{
   typealias SFVec3d = JavaScript .SFVec3d
   typealias MFVec3d = JavaScript .MFVec3d
   typealias Context = JavaScript .Context

   init ()
   
   func equals (_ array : MFVec3d) -> JSValue
   func assign (_ array : MFVec3d)

   func get1Value (_ context : Context, _ index : Int) -> SFVec3d
   func set1Value (_ index : Int, _ value : SFVec3d)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFVec3d :
      X3DArrayField,
      MFVec3dExports
   {
      typealias Internal = X3D .MFVec3d

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFVec3d"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, context, targets, \"MFVec3d\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFVec3d .self) as? SFVec3d)? .field .wrappedValue ?? .zero
            })
         }
         else
         {
            self .field = Internal ()
         }
         
         super .init (field)
      }

      internal init (field : Internal)
      {
         self .field = field
         
         super .init (field)
      }
      
      internal static func initWithProxy (field : Internal) -> JSValue!
      {
         return proxy .construct (withArguments: [MFVec3d (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFVec3d) -> JSValue
      {
         return JSValue (bool: field .wrappedValue == array .field .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFVec3d)
      {
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ context : Context, _ index : Int) -> SFVec3d
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .zero)
         }

         return SFVec3d (field: SFVec3dReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFVec3d)
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .zero)
         }
         
         field .wrappedValue [index] = value .field .wrappedValue
      }
      
      // Properties
      
      dynamic public final var length : Int
      {
         get { field .wrappedValue .count }
         set { field .wrappedValue .resize (newValue, fillWith: .zero) }
      }
   }
}

extension JavaScript
{
   internal final class SFVec3dReference :
      X3D .SFVec3d
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFVec3d
      private final let index : Int

      internal init (_ array : X3D .MFVec3d, _ index : Int)
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
