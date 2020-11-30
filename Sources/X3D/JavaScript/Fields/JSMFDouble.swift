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
   typealias Scalar     = Double
   typealias MFDouble   = JavaScript .MFDouble
   typealias X3DBrowser = JavaScript .X3DBrowser

   init ()
   
   func equals (_ array : MFDouble) -> JSValue
   func assign (_ array : MFDouble)

   func get1Value (_ browser : X3DBrowser, _ index : Int) -> Scalar
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
      
      internal private(set) final var field : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFDouble"] = Self .self
         
         proxy = context .evaluateScript ("X3DArrayFieldWrapper (this, targets, \"MFDouble\");")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .field = Internal (wrappedValue: args .map { $0 .toDouble () })
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
         return proxy .construct (withArguments: [MFDouble (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFDouble) -> JSValue
      {
         return JSValue (bool: field .wrappedValue == array .field .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFDouble)
      {
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
