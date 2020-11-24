//
//  JSSFVec3d.swift
//
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

@objc internal protocol SFVec3dExports :
   JSExport
{
   typealias Scalar = Double
   typealias SFVec  = JavaScript .SFVec3d

   var x : Scalar { get set }
   var y : Scalar { get set }
   var z : Scalar { get set }
   
   init ()
   
   func add (_ vector : SFVec) -> SFVec
   func cross (_ vector : SFVec) -> SFVec
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

   func toString () -> String
}

extension JavaScript
{
   @objc internal final class SFVec3d :
      NSObject,
      SFVec3dExports
   {
      typealias Scalar   = Double
      typealias SFVec    = JavaScript .SFVec3d
      typealias Internal = X3D .SFVec3d
      typealias Inner    = Internal .Value

      // Properties
      
      public var x : Scalar { get { object .wrappedValue .x } set { object .wrappedValue .x = newValue } }
      public var y : Scalar { get { object .wrappedValue .y } set { object .wrappedValue .y = newValue } }
      public var z : Scalar { get { object .wrappedValue .z } set { object .wrappedValue .z = newValue } }

      // Private properties
      
      private final var object : Internal
      
      // Registration
      
      public static func register (_ context : JSContext)
      {
         context .setObject (Self .self, forKeyedSubscript: "SFVec3d" as NSString)
         
         context .evaluateScript ("""
Object .defineProperty (SFVec3d .prototype, 0, {
   get: function () { return this .x; },
   set: function (newValue) { this .x = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFVec3d .prototype, 1, {
   get: function () { return this .y; },
   set: function (newValue) { this .y = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFVec3d .prototype, 2, {
   get: function () { return this .z; },
   set: function (newValue) { this .z = newValue; },
   enumerable: true,
   configurable: false,
});
""")
      }
      
      // Construction
      
      required public override init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 3
         {
            self .object = Internal (wrappedValue: Inner (args [0] .toDouble (),
                                                          args [1] .toDouble (),
                                                          args [2] .toDouble ()))
         }
         else
         {
            self .object = Internal ()
         }
      }
      
      required internal init (object : Internal)
      {
         self .object = object
      }
      
      // Functions
      
      public final func add (_ vector : SFVec) -> SFVec
      {
         return SFVec (object: Internal (wrappedValue: object .wrappedValue + vector .object .wrappedValue))
      }

      public final func cross (_ vector : SFVec) -> SFVec
      {
         return SFVec (object: Internal (wrappedValue: simd_cross (object .wrappedValue, vector .object .wrappedValue)))
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

      // Input/Output
      
      public final func toString () -> String
      {
         return object .toString ()
      }
   }
}
