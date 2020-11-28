//
//  JSSFImage.swift
//
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

@objc internal protocol SFImageExports :
   JSExport
{
   typealias SFImage = JavaScript .SFImage

   var width  : Int32 { get set }
   var x      : Int32 { get set }
   var height : Int32 { get set }
   var y      : Int32 { get set }
   var comp   : Int32 { get set }

   init ()
   
   func equals (_ color : SFImage) -> JSValue
   func assign (_ color : SFImage)
}

extension JavaScript
{
   @objc internal final class SFImage :
      X3DField,
      SFImageExports
   {
      typealias Internal = X3D .SFImage
      typealias Inner    = Internal .Value

      // Properties
      
      dynamic public var width  : Int32 { get { object .wrappedValue .width }  set { object .wrappedValue .width  = newValue } }
      dynamic public var x      : Int32 { get { object .wrappedValue .width }  set { object .wrappedValue .width  = newValue } }
      dynamic public var height : Int32 { get { object .wrappedValue .height } set { object .wrappedValue .height = newValue } }
      dynamic public var y      : Int32 { get { object .wrappedValue .height } set { object .wrappedValue .height = newValue } }
      dynamic public var comp   : Int32 { get { object .wrappedValue .comp }   set { object .wrappedValue .comp   = newValue } }

      // Private properties
      
      internal private(set) var object : Internal
      internal final override func getObject () -> X3D .X3DField! { object }

      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFImage"] = Self .self
      }
      
      // Construction
      
      public override init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 4
         {
            self .object = Internal ()
            
            self .object .wrappedValue .width  = args [0] .toInt32 ()
            self .object .wrappedValue .height = args [1] .toInt32 ()
            self .object .wrappedValue .comp   = args [2] .toInt32 ()
         }
         else
         {
            self .object = Internal ()
         }
         
         super .init ()
         
         JSContext .current () .fix (self)
      }
      
      internal init (_ context : JSContext? = nil, object : Internal)
      {
         self .object = object
         
         super .init ()
         
         (context ?? JSContext .current ()) .fix (self)
      }

      // Common operators
      
      public final func equals (_ image : SFImage) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == image .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ image : SFImage)
      {
         object .set (value: image .object)
      }
   }
}
