//
//  JSMFBool.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFBoolExports :
   JSExport
{
   typealias Scalar     = Bool
   typealias MFBool     = JavaScript .MFBool
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFBool?) -> Any?
   func assign (_ array : MFBool?)

   func get1Value (_ index : Int) -> Any
   func set1Value (_ index : Int, _ value : Scalar)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFBool :
      X3DArrayField,
      MFBoolExports
   {
      typealias Scalar   = Bool
      typealias Internal = X3D .MFBool

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFBool"] = Self .self
         
         context .evaluateScript ("MakeX3DArrayField (this, targets, true, \"MFBool\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map { $0 .toBool () })
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
         return context ["MFBool"]! .construct (withArguments: [MFBool (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFBool?) -> Any?
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFBool?)
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> Any
      {
         if index >= field .wrappedValue .count
         {
            return field .wrappedValue .resize (index + 1, fillWith: Scalar ())
         }
         
         return field .wrappedValue [index]
      }
      
      public final func set1Value (_ index : Int, _ value : Scalar)
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: Scalar ())
         }
         
         field .wrappedValue [index] = value
      }
      
      // Properties
      
      dynamic public final var length : Int
      {
         get { field .wrappedValue .count }
         set { field .wrappedValue .resize (newValue, fillWith: Scalar ()) }
      }
   }
}
