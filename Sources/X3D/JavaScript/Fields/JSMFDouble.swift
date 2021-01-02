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
   
   func equals (_ array : MFDouble?) -> Any?
   func assign (_ array : MFDouble?)

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
      
      internal private(set) final var field : Internal

      // Registration
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFDouble"] = Self .self
         
         context .evaluateScript ("MakeX3DArrayField (this, targets, true, \"MFDouble\");")
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

      private init (field : Internal)
      {
         self .field = field
         
         super .init (field)
      }
      
      internal static func initWithProxy (_ context : JSContext, field : Internal) -> JSValue!
      {
         return context ["MFDouble"]! .construct (withArguments: [MFDouble (field: field)])
      }
      
      // Common operators
      
      public final func equals (_ array : MFDouble?) -> Any?
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == array .field .wrappedValue
      }

      public final func assign (_ array : MFDouble?)
      {
         guard let array = array else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = array .field .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> Scalar
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
