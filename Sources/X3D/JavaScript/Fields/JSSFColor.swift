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
      
      dynamic public final var r : Scalar { get { object .wrappedValue .r } set { object .wrappedValue .r = newValue } }
      dynamic public final var g : Scalar { get { object .wrappedValue .g } set { object .wrappedValue .g = newValue } }
      dynamic public final var b : Scalar { get { object .wrappedValue .b } set { object .wrappedValue .b = newValue } }

      // Private properties
      
      internal private(set) final var object : Internal

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
            self .object = Internal (wrappedValue: Inner (clamp (args [0] .toFloat (), min: 0, max: 1),
                                                          clamp (args [1] .toFloat (), min: 0, max: 1),
                                                          clamp (args [2] .toFloat (), min: 0, max: 1)))
         }
         else
         {
            self .object = Internal ()
         }
         
         super .init (object)
         
         JSContext .current () .fix (self)
      }
      
      internal init (_ context : JSContext? = nil, object : Internal)
      {
         self .object = object
         
         super .init (object)
         
         (context ?? JSContext .current ()) .fix (self)
      }

      // Common operators
      
      public final func equals (_ color : SFColor) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == color .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ color : SFColor)
      {
         object .wrappedValue = color .object .wrappedValue
      }

      // Property access
      
      public final func getHSV () -> [Float]
      {
         let hsv = object .wrappedValue .hsv
         
         return [hsv [0], hsv [1], hsv [2], hsv [3]]
      }
      
      public final func setHSV (_ h : Float, _ s : Float, _ v : Float)
      {
         object .wrappedValue = Inner (h, s, v) .rgb
      }
 
      // Functions

      public final func lerp (_ color : SFColor, _ t : Float) -> SFColor
      {
         let color = hsv_mix (object .wrappedValue .hsv, color .object .wrappedValue .hsv, t: t) .rgb
         
         return SFColor (object: Internal (wrappedValue: color))
      }
   }
}
