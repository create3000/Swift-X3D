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
   
   func equals (_ color : SFColorRGBA?) -> Any?
   func assign (_ color : SFColorRGBA?)
   
   func getHSVA () -> [Float]
   func setHSVA (_ h : Float, _ s : Float, _ v : Float, _ a : Float)
   
   func lerp (_ color : SFColorRGBA?, _ t : Float) -> SFColorRGBA?
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
      
      dynamic public final var r : Scalar { get { field .wrappedValue .r } set { field .wrappedValue .r = newValue } }
      dynamic public final var g : Scalar { get { field .wrappedValue .g } set { field .wrappedValue .g = newValue } }
      dynamic public final var b : Scalar { get { field .wrappedValue .b } set { field .wrappedValue .b = newValue } }
      dynamic public final var a : Scalar { get { field .wrappedValue .a } set { field .wrappedValue .a = newValue } }

      // Private properties
      
      internal private(set) final var field : Internal

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
            self .field = Internal (wrappedValue: Inner (r: args [0] .toFloat (),
                                                         g: args [1] .toFloat (),
                                                         b: args [2] .toFloat (),
                                                         a: args [3] .toFloat ()))
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
      
      public final func equals (_ color : SFColorRGBA?) -> Any?
      {
         guard let color = color else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == color .field .wrappedValue
      }

      public final func assign (_ color : SFColorRGBA?)
      {
         guard let color = color else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = color .field .wrappedValue
      }

      // Property access
      
      public final func getHSVA () -> [Float]
      {
         let hsva = field .wrappedValue .hsva
         
         return [hsva [0], hsva [1], hsva [2], hsva [3]]
      }
      
      public final func setHSVA (_ h : Float, _ s : Float, _ v : Float, _ a : Float)
      {
         field .wrappedValue = Inner (h, s, v, a) .rgba
      }
 
      // Functions

      public final func lerp (_ color : SFColorRGBA?, _ t : Float) -> SFColorRGBA?
      {
         guard let color = color else { return exception (X3D .t("Invalid argument.")) }
         
         let result = hsva_mix (field .wrappedValue .hsva, color .field .wrappedValue .hsva, t: t) .rgba
         
         return SFColorRGBA (field: Internal (wrappedValue: result))
      }
   }
}
