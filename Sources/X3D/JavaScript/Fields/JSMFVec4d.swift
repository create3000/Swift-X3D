//
//  JSMFVec4d.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFVec4dExports :
   JSExport
{
   typealias SFVec4d    = JavaScript .SFVec4d
   typealias MFVec4d    = JavaScript .MFVec4d
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFVec4d) -> Any
   func assign (_ array : MFVec4d)

   func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFVec4d
   func set1Value (_ index : Int, _ value : SFVec4d)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFVec4d :
      X3DArrayField,
      MFVec4dExports
   {
      typealias Internal = X3D .MFVec4d

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFVec4d"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, Browser, targets, \"MFVec4d\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFVec4d .self) as? SFVec4d)? .field .wrappedValue ?? .zero
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
         return proxy .construct (withArguments: [MFVec4d (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFVec4d) -> Any
      {
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFVec4d)
      {
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFVec4d
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .zero)
         }

         return SFVec4d (field: SFVec4dReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFVec4d)
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
   internal final class SFVec4dReference :
      X3D .SFVec4d
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFVec4d
      private final let index : Int

      internal init (_ array : X3D .MFVec4d, _ index : Int)
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
