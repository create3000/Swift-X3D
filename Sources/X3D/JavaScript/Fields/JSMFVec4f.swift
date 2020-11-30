//
//  JSMFVec4f.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFVec4fExports :
   JSExport
{
   typealias SFVec4f    = JavaScript .SFVec4f
   typealias MFVec4f    = JavaScript .MFVec4f
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFVec4f) -> JSValue
   func assign (_ array : MFVec4f)

   func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFVec4f
   func set1Value (_ index : Int, _ value : SFVec4f)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFVec4f :
      X3DArrayField,
      MFVec4fExports
   {
      typealias Internal = X3D .MFVec4f

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFVec4f"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, targets, \"MFVec4f\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFVec4f .self) as? SFVec4f)? .field .wrappedValue ?? .zero
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
         return proxy .construct (withArguments: [MFVec4f (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFVec4f) -> JSValue
      {
         return JSValue (bool: field .wrappedValue == array .field .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFVec4f)
      {
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFVec4f
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .zero)
         }

         return SFVec4f (field: SFVec4fReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFVec4f)
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
   internal final class SFVec4fReference :
      X3D .SFVec4f
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFVec4f
      private final let index : Int

      internal init (_ array : X3D .MFVec4f, _ index : Int)
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
