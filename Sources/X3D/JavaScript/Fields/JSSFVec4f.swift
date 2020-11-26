//
//  JSSFVec4f.swift
//
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

@objc internal protocol SFVec4fExports :
   JSExport
{
   typealias Scalar = Float
   typealias SFVec  = JavaScript .SFVec4f

   var x : Scalar { get set }
   var y : Scalar { get set }
   var z : Scalar { get set }
   var w : Scalar { get set }

   init ()
   
   func equals (_ vector : SFVec) -> JSValue
   func assign (_ vector : SFVec)

   func add (_ vector : SFVec) -> SFVec
   func distance (_ vector : SFVec) -> Scalar
   func divide (_ scalar : Scalar) -> SFVec
   func divVec (_ vector : SFVec) -> SFVec
   func length () -> Scalar
   func lerp (_ vector : SFVec, _ t : Scalar) -> SFVec
   func multiply (_ scalar : Scalar) -> SFVec
   func multVec (_ vector : SFVec) -> SFVec
   func negate () -> SFVec
   func normalize () -> SFVec
   func subtract (_ vector : SFVec) -> SFVec
}

extension JavaScript
{
   @objc internal final class SFVec4f :
      X3DField,
      SFVec4fExports
   {
      typealias Scalar   = Float
      typealias SFVec    = JavaScript .SFVec4f
      typealias Internal = X3D .SFVec4f
      typealias Inner    = Internal .Value

      // Properties
      
      dynamic public var x : Scalar { get { object .wrappedValue .x } set { object .wrappedValue .x = newValue } }
      dynamic public var y : Scalar { get { object .wrappedValue .y } set { object .wrappedValue .y = newValue } }
      dynamic public var z : Scalar { get { object .wrappedValue .z } set { object .wrappedValue .z = newValue } }
      dynamic public var w : Scalar { get { object .wrappedValue .w } set { object .wrappedValue .w = newValue } }

      // Private properties
      
      internal private(set) final var object : Internal
      
      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFVec4f"] = Self .self
         
         context .evaluateScript ("""
Object .defineProperty (SFVec4f .prototype, 0, {
   get: function () { return this .x; },
   set: function (newValue) { this .x = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFVec4f .prototype, 1, {
   get: function () { return this .y; },
   set: function (newValue) { this .y = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFVec4f .prototype, 2, {
   get: function () { return this .z; },
   set: function (newValue) { this .z = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFVec4f .prototype, 3, {
   get: function () { return this .w; },
   set: function (newValue) { this .w = newValue; },
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
            self .object = Internal (wrappedValue: Inner (args [0] .toFloat (),
                                                          args [1] .toFloat (),
                                                          args [2] .toFloat (),
                                                          args [3] .toFloat ()))
         }
         else
         {
            self .object = Internal ()
         }
         
         super .init (self .object)
         
         JSContext .current () .fix (self)
     }
      
      required internal init (_ context : JSContext? = nil, object : Internal)
      {
         self .object = object
         
         super .init (self .object)
         
         (context ?? JSContext .current ()) .fix (self)
      }

      // Common operators
      
      public final func equals (_ vector : SFVec) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == vector .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ vector : SFVec)
      {
         object .wrappedValue = vector .object .wrappedValue
      }

      // Functions
      
      public final func add (_ vector : SFVec) -> SFVec
      {
         return SFVec (object: Internal (wrappedValue: object .wrappedValue + vector .object .wrappedValue))
      }

      public final func distance (_ vector : SFVec) -> Scalar
      {
         return simd_distance (object .wrappedValue, vector .object .wrappedValue)
      }

      public final func divide (_ scalar : Scalar) -> SFVec
      {
         return SFVec (object: Internal (wrappedValue: object .wrappedValue / scalar))
      }
      
      public final func divVec (_ vector : SFVec) -> SFVec
      {
         return SFVec (object: Internal (wrappedValue: object .wrappedValue / vector .object .wrappedValue))
      }

      public final func length () -> Scalar
      {
         return simd_length (object .wrappedValue)
      }
      
      public final func lerp (_ vector : SFVec, _ t : Scalar) -> SFVec
      {
         return SFVec (object: Internal (wrappedValue: mix (object .wrappedValue, vector .object .wrappedValue, t: t)))
      }

      public final func multiply (_ scalar : Scalar) -> SFVec
      {
         return SFVec (object: Internal (wrappedValue: object .wrappedValue * scalar))
      }
      
      public final func multVec (_ vector : SFVec) -> SFVec
      {
         return SFVec (object: Internal (wrappedValue: object .wrappedValue * vector .object .wrappedValue))
      }

      public final func negate () -> SFVec
      {
         return SFVec (object: Internal (wrappedValue: -object .wrappedValue))
      }

      public final func normalize () -> SFVec
      {
         return SFVec (object: Internal (wrappedValue: simd_normalize (object .wrappedValue)))
      }

      public final func subtract (_ vector : SFVec) -> SFVec
      {
         return SFVec (object: Internal (wrappedValue: object .wrappedValue - vector .object .wrappedValue))
      }
   }
}