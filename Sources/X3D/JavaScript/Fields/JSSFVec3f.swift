//
//  JSSFVec3f.swift
//  
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

@objc internal protocol SFVec3fExports :
   JSExport
{
   typealias Scalar = Float
   typealias SFVec  = JavaScript .SFVec3f

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
   @objc internal final class SFVec3f :
      NSObject,
      SFVec3fExports
   {
      typealias Scalar   = Float
      typealias SFVec    = JavaScript .SFVec3f
      typealias Internal = X3D .SFVec3f

      // Properties
      
      public var x : Scalar { get { object .wrappedValue .x } set { object .wrappedValue .x = newValue } }
      public var y : Scalar { get { object .wrappedValue .y } set { object .wrappedValue .y = newValue } }
      public var z : Scalar { get { object .wrappedValue .z } set { object .wrappedValue .z = newValue } }

      // Private properties
      
      private final var object : Internal
      
      // Registration
      
      public static func register (_ context : JSContext)
      {
         context .setObject (Self .self, forKeyedSubscript: "SFVec3f" as NSString)
         
         context .evaluateScript ("""
Object .defineProperty (SFVec3f .prototype, "0", {
   get: function () { return this .x; },
   set: function (newValue) { this .x = newValue; },
   enumerable: true,
   configurable: false
});
Object .defineProperty (SFVec3f .prototype, "1", {
   get: function () { return this .y; },
   set: function (newValue) { this .y = newValue; },
   enumerable: true,
   configurable: false
});
Object .defineProperty (SFVec3f .prototype, "2", {
   get: function () { return this .z; },
   set: function (newValue) { this .z = newValue; },
   enumerable: true,
   configurable: false
});
""")
      }
      
      // Construction
      
      required public override init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 3
         {
            self .object = Internal (wrappedValue: Vector3f (args [0] .toFloat (),
                                                             args [1] .toFloat (),
                                                             args [2] .toFloat ()))
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