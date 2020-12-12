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
   
   func equals (_ vector : SFVec?) -> Any
   func assign (_ vector : SFVec?)

   func add (_ vector : SFVec?) -> SFVec?
   func cross (_ vector : SFVec?) -> SFVec?
   func distance (_ vector : SFVec?) -> Scalar
   func divide (_ scalar : Scalar) -> SFVec
   func divVec (_ vector : SFVec?) -> SFVec?
   func dot (_ vector : SFVec?) -> Scalar
   func length () -> Scalar
   func lerp (_ vector : SFVec?, _ t : Scalar) -> SFVec?
   func multiply (_ scalar : Scalar) -> SFVec
   func multVec (_ vector : SFVec?) -> SFVec?
   func negate () -> SFVec
   func normalize () -> SFVec
   func subtract (_ vector : SFVec?) -> SFVec?
}

extension JavaScript
{
   @objc internal final class SFVec3f :
      X3DField,
      SFVec3fExports
   {
      typealias Scalar   = Float
      typealias SFVec    = JavaScript .SFVec3f
      typealias Internal = X3D .SFVec3f
      typealias Inner    = Internal .Value

      // Properties
      
      dynamic public final var x : Scalar { get { field .wrappedValue .x } set { field .wrappedValue .x = newValue } }
      dynamic public final var y : Scalar { get { field .wrappedValue .y } set { field .wrappedValue .y = newValue } }
      dynamic public final var z : Scalar { get { field .wrappedValue .z } set { field .wrappedValue .z = newValue } }

      // Private properties
      
      internal private(set) final var field : Internal
      
      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFVec3f"] = Self .self

         context .evaluateScript ("""
Object .defineProperty (SFVec3f .prototype, 0, {
   get: function () { return this .x; },
   set: function (newValue) { this .x = newValue; },
   enumerable: true,
   configurable: false,
});

Object .defineProperty (SFVec3f .prototype, 1, {
   get: function () { return this .y; },
   set: function (newValue) { this .y = newValue; },
   enumerable: true,
   configurable: false,
});

Object .defineProperty (SFVec3f .prototype, 2, {
   get: function () { return this .z; },
   set: function (newValue) { this .z = newValue; },
   enumerable: true,
   configurable: false,
});

DefineProperty (this, "SFVec3f", SFVec3f);
""")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 3
         {
            self .field = Internal (wrappedValue: Inner (args [0] .toFloat (),
                                                         args [1] .toFloat (),
                                                         args [2] .toFloat ()))
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
      
      public final func equals (_ vector : SFVec?) -> Any
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         return field .wrappedValue == vector .field .wrappedValue
      }

      public final func assign (_ vector : SFVec?)
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         field .wrappedValue = vector .field .wrappedValue
      }

      // Functions
      
      public final func add (_ vector : SFVec?) -> SFVec?
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         return SFVec (field: Internal (wrappedValue: field .wrappedValue + vector .field .wrappedValue))
      }

      public final func cross (_ vector : SFVec?) -> SFVec?
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         return SFVec (field: Internal (wrappedValue: simd_cross (field .wrappedValue, vector .field .wrappedValue)))
      }

      public final func distance (_ vector : SFVec?) -> Scalar
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         return simd_distance (field .wrappedValue, vector .field .wrappedValue)
      }

      public final func divide (_ scalar : Scalar) -> SFVec
      {
         return SFVec (field: Internal (wrappedValue: field .wrappedValue / scalar))
      }
      
      public final func divVec (_ vector : SFVec?) -> SFVec?
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         return SFVec (field: Internal (wrappedValue: field .wrappedValue / vector .field .wrappedValue))
      }
      
      public final func dot (_ vector : SFVec?) -> Scalar
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         return simd_dot (field .wrappedValue, vector .field .wrappedValue)
      }

      public final func length () -> Scalar
      {
         return simd_length (field .wrappedValue)
      }
      
      public final func lerp (_ vector : SFVec?, _ t : Scalar) -> SFVec?
      {
         guard let vector = vector else { return exception (X3D .t("Invalid argument.")) }
         
         return SFVec (field: Internal (wrappedValue: mix (field .wrappedValue, vector .field .wrappedValue, t: t)))
      }

      public final func multiply (_ scalar : Scalar) -> SFVec
      {
         return SFVec (field: Internal (wrappedValue: field .wrappedValue * scalar))
      }
      
      public final func multVec (_ vector : SFVec?) -> SFVec?
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         return SFVec (field: Internal (wrappedValue: field .wrappedValue * vector .field .wrappedValue))
      }

      public final func negate () -> SFVec
      {
         return SFVec (field: Internal (wrappedValue: -field .wrappedValue))
      }

      public final func normalize () -> SFVec
      {
         return SFVec (field: Internal (wrappedValue: simd_normalize (field .wrappedValue)))
      }

      public final func subtract (_ vector : SFVec?) -> SFVec?
      {
         guard let vector = vector else { return exception (t("Invalid argument.")) }
         
         return SFVec (field: Internal (wrappedValue: field .wrappedValue - vector .field .wrappedValue))
      }
   }
}
