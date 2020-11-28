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
   typealias SFColor = JavaScript .SFColor
   typealias MFColor = JavaScript .MFColor
   
   init ()
   
   func equals (_ array : MFColor) -> JSValue
   func assign (_ array : MFColor)

   func get1Value (_ index : Int) -> SFColor
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
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFColor"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, \"MFColor\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFColor .self) as? SFColor)? .object .wrappedValue ?? .zero
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
         return proxy .construct (withArguments: [MFColor (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFColor) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFColor)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFColor
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: .zero)
         }

         return SFColor (object: SFColorReference (object, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFColor)
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
