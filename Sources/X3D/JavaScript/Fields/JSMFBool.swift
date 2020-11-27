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
   typealias Scalar = Bool
   typealias MFBool = JavaScript .MFBool
   
   var length : Int { get set }
   
   init ()
   
   func equals (_ array : MFBool) -> JSValue
   func assign (_ array : MFBool)

   func get1Value (_ index : Int) -> JSValue
   func set1Value (_ index : Int, _ value : Scalar)
}

extension JavaScript
{
   @objc internal class MFBool :
      X3DArrayField,
      MFBoolExports
   {
      typealias Scalar   = Bool
      typealias Internal = X3D .MFBool
      
      // Properties
      
      dynamic public var length : Int
      {
         get { object .wrappedValue .count }
         set { object .wrappedValue .resize (newValue, fillWith: Scalar ()) }
      }

      // Private properties
      
      internal private(set) final var object : Internal
      
      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFBool"] = Self .self
         
         proxy = context .evaluateScript ("NativeArray (this, \"MFBool\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map { $0 .toBool () })
         }
         else
         {
            self .object = Internal ()
         }
         
         super .init (self .object)
      }

      required internal init (object : Internal)
      {
         self .object = object
         
         super .init (self .object)
      }
      
      internal static func initWithProxy (object : Internal) -> JSValue!
      {
         return proxy .construct (withArguments: [Self (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFBool) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFBool)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> JSValue
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: Scalar ())
         }
         
         return JSValue (bool: object .wrappedValue [index], in: JSContext .current ())
      }
      
      public final func set1Value (_ index : Int, _ value : Scalar)
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: Scalar ())
         }
         
         object .wrappedValue [index] = value
      }
   }
}
