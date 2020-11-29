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
      
      dynamic public final var width  : Int32 { get { field .wrappedValue .width }  set { field .wrappedValue .width  = newValue } }
      dynamic public final var x      : Int32 { get { field .wrappedValue .width }  set { field .wrappedValue .width  = newValue } }
      dynamic public final var height : Int32 { get { field .wrappedValue .height } set { field .wrappedValue .height = newValue } }
      dynamic public final var y      : Int32 { get { field .wrappedValue .height } set { field .wrappedValue .height = newValue } }
      dynamic public final var comp   : Int32 { get { field .wrappedValue .comp }   set { field .wrappedValue .comp   = newValue } }

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFImage"] = Self .self
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 4
         {
            self .field = Internal ()
            
            self .field .wrappedValue .width  = args [0] .toInt32 ()
            self .field .wrappedValue .height = args [1] .toInt32 ()
            self .field .wrappedValue .comp   = args [2] .toInt32 ()
         }
         else
         {
            self .field = Internal ()
         }
         
         super .init (field)
         
         JSContext .current () .fix (self)
      }
      
      internal init (_ context : JSContext? = nil, field : Internal)
      {
         self .field = field
         
         super .init (field)
         
         (context ?? JSContext .current ()) .fix (self)
      }

      // Common operators
      
      public final func equals (_ image : SFImage) -> JSValue
      {
         return JSValue (bool: field .wrappedValue == image .field .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ image : SFImage)
      {
         field .set (value: image .field)
      }
   }
}
