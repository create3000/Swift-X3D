//
//  JSMFVec2d.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFVec2dExports :
   JSExport
{
   typealias SFVec2d    = JavaScript .SFVec2d
   typealias MFVec2d    = JavaScript .MFVec2d
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFVec2d?) -> Any?
   func assign (_ array : MFVec2d?)

   func get1Value (_ index : Int) -> SFVec2d
   func set1Value (_ index : Int, _ value : SFVec2d?)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFVec2d :
      X3DArrayField,
      MFVec2dExports
   {
      typealias Internal = X3D .MFVec2d

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFVec2d"] = Self .self
         
         context .evaluateScript ("MakeX3DArrayField (this, targets, true, \"MFVec2d\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFVec2d .self) as? SFVec2d)? .field .wrappedValue ?? .zero
            })
         }
         else
         {
            self .field = Internal ()
         }
         
         super .init (field)
      }

      private init (field : Internal)
      {
         self .field = field
         
         super .init (field)
      }
      
      internal static func initWithProxy (_ context : JSContext, field : Internal) -> JSValue!
      {
         return context ["MFVec2d"]! .construct (withArguments: [MFVec2d (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFVec2d?) -> Any?
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFVec2d?)
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFVec2d
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .zero)
         }

         return SFVec2d (field: SFVec2dReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFVec2d?)
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
   internal final class SFVec2dReference :
      X3D .SFVec2d
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFVec2d
      private final let index : Int

      internal init (_ array : X3D .MFVec2d, _ index : Int)
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
