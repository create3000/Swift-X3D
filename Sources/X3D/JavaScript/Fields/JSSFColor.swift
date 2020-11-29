//
//  JSSFColor.swift
//
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

@objc internal protocol SFColorExports :
   JSExport
{
   typealias Scalar  = Float
   typealias SFColor = JavaScript .SFColor

   var r : Scalar { get set }
   var g : Scalar { get set }
   var b : Scalar { get set }

   init ()
   
   func equals (_ color : SFColor) -> JSValue
   func assign (_ color : SFColor)
   
   func getHSV () -> [Float]
   func setHSV (_ h : Float, _ s : Float, _ v : Float)
   
   func lerp (_ color : SFColor, _ t : Float) -> SFColor
}

extension JavaScript
{
   @objc internal final class SFColor :
      X3DField,
      SFColorExports
   {
      typealias Scalar   = Float
      typealias Internal = X3D .SFColor
      typealias Inner    = Internal .Value

      // Properties
      
      dynamic public final var r : Scalar { get { field .wrappedValue .r } set { field .wrappedValue .r = newValue } }
      dynamic public final var g : Scalar { get { field .wrappedValue .g } set { field .wrappedValue .g = newValue } }
      dynamic public final var b : Scalar { get { field .wrappedValue .b } set { field .wrappedValue .b = newValue } }

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFColor"] = Self .self
         
         context .evaluateScript ("""
Object .defineProperty (SFColor .prototype, 0, {
   get: function () { return this .r; },
   set: function (newValue) { this .r = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFColor .prototype, 1, {
   get: function () { return this .g; },
   set: function (newValue) { this .g = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFColor .prototype, 2, {
   get: function () { return this .b; },
   set: function (newValue) { this .b = newValue; },
   enumerable: true,
   configurable: false,
});
""")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 3
         {
            self .field = Internal (wrappedValue: Inner (r: args [0] .toFloat (),
                                                          g: args [1] .toFloat (),
                                                          b: args [2] .toFloat ()))
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
      
      public final func equals (_ color : SFColor) -> JSValue
      {
         return JSValue (bool: field .wrappedValue == color .field .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ color : SFColor)
      {
         field .wrappedValue = color .field .wrappedValue
      }

      // Property access
      
      public final func getHSV () -> [Float]
      {
         let hsv = field .wrappedValue .hsv
         
         return [hsv [0], hsv [1], hsv [2], hsv [3]]
      }
      
      public final func setHSV (_ h : Float, _ s : Float, _ v : Float)
      {
         field .wrappedValue = Inner (h, s, v) .rgb
      }
 
      // Functions

      public final func lerp (_ color : SFColor, _ t : Float) -> SFColor
      {
         let color = hsv_mix (field .wrappedValue .hsv, color .field .wrappedValue .hsv, t: t) .rgb
         
         return SFColor (field: Internal (wrappedValue: color))
      }
   }
}
