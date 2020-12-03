//
//  JSMFMatrix4f.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFMatrix4fExports :
   JSExport
{
   typealias SFMatrix4f = JavaScript .SFMatrix4f
   typealias MFMatrix4f = JavaScript .MFMatrix4f
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFMatrix4f?) -> Any?
   func assign (_ array : MFMatrix4f?)

   func get1Value (_ index : Int) -> SFMatrix4f
   func set1Value (_ index : Int, _ value : SFMatrix4f?)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFMatrix4f :
      X3DArrayField,
      MFMatrix4fExports
   {
      typealias Internal = X3D .MFMatrix4f

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFMatrix4f"] = Self .self
         
         context .evaluateScript ("X3DArrayFieldWrapper (this, targets, true, \"MFMatrix4f\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFMatrix4f .self) as? SFMatrix4f)? .field .wrappedValue ?? .identity
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
      
      internal static func initWithProxy (_ context : JSContext, field : Internal) -> JSValue!
      {
         return context ["MFMatrix4f"]! .construct (withArguments: [MFMatrix4f (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFMatrix4f?) -> Any?
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFMatrix4f?)
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFMatrix4f
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .identity)
         }

         return SFMatrix4f (field: SFMatrix4fReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFMatrix4f?)
      {
         guard let value = value else { return exception (t("Invalid argument.")) }
         
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
   internal final class SFMatrix4fReference :
      X3D .SFMatrix4f
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFMatrix4f
      private final let index : Int

      internal init (_ array : X3D .MFMatrix4f, _ index : Int)
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
