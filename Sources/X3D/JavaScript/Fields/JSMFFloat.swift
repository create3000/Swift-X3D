//
//  JSMFFloat.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFFloatExports :
   JSExport
{
   typealias Scalar  = Float
   typealias MFFloat = JavaScript .MFFloat
   
   init ()
   
   func equals (_ array : MFFloat) -> JSValue
   func assign (_ array : MFFloat)

   func get1Value (_ index : Int) -> Scalar
   func set1Value (_ index : Int, _ value : Scalar)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFFloat :
      X3DArrayField,
      MFFloatExports
   {
      typealias Scalar   = Float
      typealias Internal = X3D .MFFloat

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFFloat"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, targets, \"MFFloat\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map { $0 .toFloat () })
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
         return proxy .construct (withArguments: [MFFloat (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFFloat) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFFloat)
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
