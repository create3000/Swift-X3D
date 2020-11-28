//
//  JSMFDouble.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFDoubleExports :
   JSExport
{
   typealias Scalar   = Double
   typealias MFDouble = JavaScript .MFDouble
   
   init ()
   
   func equals (_ array : MFDouble) -> JSValue
   func assign (_ array : MFDouble)

   func get1Value (_ index : Int) -> Scalar
   func set1Value (_ index : Int, _ value : Scalar)
   
   var length : Int { get set }
}

extension JavaScript
{
   @objc internal class MFDouble :
      X3DArrayField,
      MFDoubleExports
   {
      typealias Scalar   = Double
      typealias Internal = X3D .MFDouble

      // Private properties
      
      internal private(set) final var object : Internal
      internal final override func getObject () -> X3D .X3DField! { object }

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFDouble"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, \"MFDouble\");")
      }
      
      // Construction
      
      required public override init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map { $0 .toDouble () })
         }
         else
         {
            self .object = Internal ()
         }
         
         super .init ()
      }

      internal init (object : Internal)
      {
         self .object = object
         
         super .init ()
      }
      
      internal static func initWithProxy (object : Internal) -> JSValue!
      {
         return proxy .construct (withArguments: [MFDouble (object: object)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFDouble) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFDouble)
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
      
      dynamic public var length : Int
      {
         get { object .wrappedValue .count }
         set { object .wrappedValue .resize (newValue, fillWith: Scalar ()) }
      }
   }
}
