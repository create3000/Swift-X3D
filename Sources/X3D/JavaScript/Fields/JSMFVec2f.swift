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
   typealias SFVec2f    = JavaScript .SFVec2f
   typealias MFVec2f    = JavaScript .MFVec2f
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFVec2f) -> JSValue
   func assign (_ array : MFVec2f)

   func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFVec2f
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
      
      internal private(set) final var field : Internal

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
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFVec2f .self) as? SFVec2f)? .field .wrappedValue ?? .zero
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
         return proxy .construct (withArguments: [MFVec2f (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFVec2f) -> JSValue
      {
         return JSValue (bool: field .wrappedValue == array .field .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFVec2f)
      {
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFVec2f
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .zero)
         }

         return SFVec2f (field: SFVec2fReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFVec2f)
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
