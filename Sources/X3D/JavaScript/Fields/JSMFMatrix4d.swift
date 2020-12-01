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
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFMatrix4d) -> Any
   func assign (_ array : MFMatrix4d)

   func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFMatrix4d
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
      
      internal private(set) final var field : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFMatrix4d"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, targets, \"MFMatrix4d\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFMatrix4d .self) as? SFMatrix4d)? .field .wrappedValue ?? .identity
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
         return proxy .construct (withArguments: [MFMatrix4d (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFMatrix4d) -> Any
      {
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFMatrix4d)
      {
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFMatrix4d
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .identity)
         }

         return SFMatrix4d (field: SFMatrix4dReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFMatrix4d)
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .identity)
         }
         
         field .wrappedValue [index] = value .field .wrappedValue
      }
      
      // Properties
      
      dynamic public final var length : Int
      {
         get { field .wrappedValue .count }
         set { field .wrappedValue .resize (newValue, fillWith: .identity) }
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
