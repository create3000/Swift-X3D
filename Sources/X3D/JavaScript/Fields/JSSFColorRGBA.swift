//
//  JSSFColorRGBA.swift
//
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

@objc internal protocol SFColorRGBAExports :
   JSExport
{
   typealias Scalar      = Float
   typealias SFColorRGBA = JavaScript .SFColorRGBA

   var r : Scalar { get set }
   var g : Scalar { get set }
   var b : Scalar { get set }
   var a : Scalar { get set }

   init ()
   
   func equals (_ color : SFColorRGBA) -> JSValue
   func assign (_ color : SFColorRGBA)
   
   func getHSVA () -> [Float]
   func setHSVA (_ h : Float, _ s : Float, _ v : Float, _ a : Float)
   
   func lerp (_ color : SFColorRGBA, _ t : Float) -> SFColorRGBA
}

extension JavaScript
{
   @objc internal final class SFColorRGBA :
      X3DField,
      SFColorRGBAExports
   {
      typealias Scalar   = Float
      typealias Internal = X3D .SFColorRGBA
      typealias Inner    = Internal .Value

      // Properties
      
      dynamic public final var r : Scalar { get { object .wrappedValue .r } set { object .wrappedValue .r = newValue } }
      dynamic public final var g : Scalar { get { object .wrappedValue .g } set { object .wrappedValue .g = newValue } }
      dynamic public final var b : Scalar { get { object .wrappedValue .b } set { object .wrappedValue .b = newValue } }
      dynamic public final var a : Scalar { get { object .wrappedValue .a } set { object .wrappedValue .a = newValue } }

      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFColorRGBA"] = Self .self
         
         context .evaluateScript ("""
Object .defineProperty (SFColorRGBA .prototype, 0, {
   get: function () { return this .r; },
   set: function (newValue) { this .r = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFColorRGBA .prototype, 1, {
   get: function () { return this .g; },
   set: function (newValue) { this .g = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFColorRGBA .prototype, 2, {
   get: function () { return this .b; },
   set: function (newValue) { this .b = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFColorRGBA .prototype, 3, {
   get: function () { return this .a; },
   set: function (newValue) { this .a = newValue; },
   enumerable: true,
   configurable: false,
});
""")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 4
         {
            self .object = Internal (wrappedValue: Inner (clamp (args [0] .toFloat (), min: 0, max: 1),
                                                          clamp (args [1] .toFloat (), min: 0, max: 1),
                                                          clamp (args [2] .toFloat (), min: 0, max: 1),
                                                          clamp (args [3] .toFloat (), min: 0, max: 1)))
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
      
      public final func equals (_ color : SFColorRGBA) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == color .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ color : SFColorRGBA)
      {
         object .wrappedValue = color .object .wrappedValue
      }

      // Property access
      
      public final func getHSVA () -> [Float]
      {
         let hsva = object .wrappedValue .hsva
         
         return [hsva [0], hsva [1], hsva [2], hsva [3]]
      }
      
      public final func setHSVA (_ h : Float, _ s : Float, _ v : Float, _ a : Float)
      {
         object .wrappedValue = Inner (h, s, v, a) .rgba
      }
 
      // Functions

      public final func lerp (_ color : SFColorRGBA, _ t : Float) -> SFColorRGBA
      {
         let color = hsva_mix (object .wrappedValue .hsva, color .object .wrappedValue .hsva, t: t) .rgba
         
         return SFColorRGBA (object: Internal (wrappedValue: color))
      }
   }
}
