//
//  JSMFColorRGBA.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFColorRGBAExports :
   JSExport
{
   typealias SFColorRGBA = JavaScript .SFColorRGBA
   typealias MFColorRGBA = JavaScript .MFColorRGBA
   typealias X3DBrowser  = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFColorRGBA) -> Any
   func assign (_ array : MFColorRGBA)

   func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFColorRGBA
   func set1Value (_ index : Int, _ value : SFColorRGBA)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFColorRGBA :
      X3DArrayField,
      MFColorRGBAExports
   {
      typealias Internal = X3D .MFColorRGBA

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFColorRGBA"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, targets, \"MFColorRGBA\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFColorRGBA .self) as? SFColorRGBA)? .field .wrappedValue ?? .zero
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
         return proxy .construct (withArguments: [MFColorRGBA (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFColorRGBA) -> Any
      {
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFColorRGBA)
      {
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFColorRGBA
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .zero)
         }

         return SFColorRGBA (field: SFColorRGBAReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFColorRGBA)
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
   internal final class SFColorRGBAReference :
      X3D .SFColorRGBA
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFColorRGBA
      private final let index : Int

      internal init (_ array : X3D .MFColorRGBA, _ index : Int)
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
