//
//  JSMFColor.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFColorExports :
   JSExport
{
   typealias SFColor    = JavaScript .SFColor
   typealias MFColor    = JavaScript .MFColor
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFColor) -> JSValue
   func assign (_ array : MFColor)

   func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFColor
   func set1Value (_ index : Int, _ value : SFColor)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFColor :
      X3DArrayField,
      MFColorExports
   {
      typealias Internal = X3D .MFColor

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFColor"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, targets, \"MFColor\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFColor .self) as? SFColor)? .field .wrappedValue ?? .zero
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
         return proxy .construct (withArguments: [MFColor (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFColor) -> JSValue
      {
         return JSValue (bool: field .wrappedValue == array .field .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFColor)
      {
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFColor
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .zero)
         }

         return SFColor (field: SFColorReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFColor)
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
   internal final class SFColorReference :
      X3D .SFColor
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFColor
      private final let index : Int

      internal init (_ array : X3D .MFColor, _ index : Int)
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
