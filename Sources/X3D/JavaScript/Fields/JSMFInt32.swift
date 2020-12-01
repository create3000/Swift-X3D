//
//  JSMFInt32.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFInt32Exports :
   JSExport
{
   typealias Scalar     = Int32
   typealias MFInt32    = JavaScript .MFInt32
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFInt32?) -> Any?
   func assign (_ array : MFInt32?)

   func get1Value (_ browser : X3DBrowser, _ index : Int) -> Scalar
   func set1Value (_ index : Int, _ value : Scalar)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFInt32 :
      X3DArrayField,
      MFInt32Exports
   {
      typealias Scalar   = Int32
      typealias Internal = X3D .MFInt32

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFInt32"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, Browser, targets, \"MFInt32\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map { $0 .toInt32 () })
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
         return proxy .construct (withArguments: [MFInt32 (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFInt32?) -> Any?
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFInt32?)
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ browser : X3DBrowser, _ index : Int) -> Scalar
      {
         if index >= field .wrappedValue .count
         {
            field .wrappedValue .resize (index + 1, fillWith: Scalar ())
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
