//
//  JSMFVec3f.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFVec3fExports :
   JSExport
{
   typealias SFVec3f    = JavaScript .SFVec3f
   typealias MFVec3f    = JavaScript .MFVec3f
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFVec3f?) -> Any?
   func assign (_ array : MFVec3f?)

   func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFVec3f
   func set1Value (_ index : Int, _ value : SFVec3f?)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFVec3f :
      X3DArrayField,
      MFVec3fExports
   {
      typealias Internal = X3D .MFVec3f

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFVec3f"] = Self .self
         
         context .evaluateScript ("X3DArrayFieldWrapper (this, Browser, targets, \"MFVec3f\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFVec3f .self) as? SFVec3f)? .field .wrappedValue ?? .zero
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
         return context ["MFVec3f"]! .construct (withArguments: [MFVec3f (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFVec3f?) -> Any?
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFVec3f?)
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ browser : X3DBrowser, _ index : Int) -> SFVec3f
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .zero)
         }

         return SFVec3f (field: SFVec3fReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFVec3f?)
      {
         guard let value = value else { return exception (t("Invalid argument.")) }
         
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
   internal final class SFVec3fReference :
      X3D .SFVec3f
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFVec3f
      private final let index : Int

      internal init (_ array : X3D .MFVec3f, _ index : Int)
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
