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
   typealias Scalar  = Int32
   typealias MFInt32 = JavaScript .MFInt32
   
   init ()
   
   func equals (_ array : MFInt32) -> JSValue
   func assign (_ array : MFInt32)

   func get1Value (_ index : Int) -> Scalar
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
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFInt32"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, targets, \"MFInt32\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map { $0 .toInt32 () })
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
         return proxy .construct (withArguments: [MFInt32 (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFInt32) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFInt32)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> Scalar
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: Scalar ())
         }
         
         return object .wrappedValue [index]
      }
      
      public final func set1Value (_ index : Int, _ value : Scalar)
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: Scalar ())
         }
         
         object .wrappedValue [index] = value
      }
      
      // Properties
      
      dynamic public final var length : Int
      {
         get { object .wrappedValue .count }
         set { object .wrappedValue .resize (newValue, fillWith: Scalar ()) }
      }
   }
}
