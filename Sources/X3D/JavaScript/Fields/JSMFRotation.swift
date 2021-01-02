//
//  JSMFRotation.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFRotationExports :
   JSExport
{
   typealias SFRotation = JavaScript .SFRotation
   typealias MFRotation = JavaScript .MFRotation
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFRotation?) -> Any?
   func assign (_ array : MFRotation?)

   func get1Value (_ index : Int) -> SFRotation
   func set1Value (_ index : Int, _ value : SFRotation?)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFRotation :
      X3DArrayField,
      MFRotationExports
   {
      typealias Internal = X3D .MFRotation

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFRotation"] = Self .self
         
         context .evaluateScript ("MakeX3DArrayField (this, targets, true, \"MFRotation\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map
            {
               ($0 .toObjectOf (SFRotation .self) as? SFRotation)? .field .wrappedValue ?? .identity
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
         return context ["MFRotation"]! .construct (withArguments: [MFRotation (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFRotation?) -> Any?
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFRotation?)
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> SFRotation
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: .identity)
         }

         return SFRotation (field: SFRotationReference (field, index))
      }
      
      public final func set1Value (_ index : Int, _ value : SFRotation?)
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
   internal final class SFRotationReference :
      X3D .SFRotation
   {
      public final override var wrappedValue : Value
      {
         get { resizeIfNeeded (); return array .wrappedValue [index] }
         set { resizeIfNeeded (); array .wrappedValue [index] = newValue }
      }
      
      private final let array : X3D .MFRotation
      private final let index : Int

      internal init (_ array : X3D .MFRotation, _ index : Int)
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
