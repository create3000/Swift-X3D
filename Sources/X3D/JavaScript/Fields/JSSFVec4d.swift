//
//  JSSFVec4d.swift
//
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

@objc internal protocol SFVec4dExports :
   JSExport
{
   typealias Scalar = Double
   typealias SFVec  = JavaScript .SFVec4d

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
   @objc internal final class SFVec4d :
      X3DField,
      SFVec4dExports
   {
      typealias Scalar   = Double
      typealias SFVec    = JavaScript .SFVec4d
      typealias Internal = X3D .SFVec4d
      typealias Inner    = Internal .Value

      // Properties
      
      dynamic public final var x : Scalar { get { field .wrappedValue .x } set { field .wrappedValue .x = newValue } }
      dynamic public final var y : Scalar { get { field .wrappedValue .y } set { field .wrappedValue .y = newValue } }
      dynamic public final var z : Scalar { get { field .wrappedValue .z } set { field .wrappedValue .z = newValue } }
      dynamic public final var w : Scalar { get { field .wrappedValue .w } set { field .wrappedValue .w = newValue } }

      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      public final override class func register (_ context : JSContext)
     {
         context ["SFVec4d"] = Self .self

         context .evaluateScript ("""
Object .defineProperty (SFVec4d .prototype, 0, {
   get: function () { return this .x; },
   set: function (newValue) { this .x = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFVec4d .prototype, 1, {
   get: function () { return this .y; },
   set: function (newValue) { this .y = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFVec4d .prototype, 2, {
   get: function () { return this .z; },
   set: function (newValue) { this .z = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFVec4d .prototype, 3, {
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
            self .field = Internal (wrappedValue: Inner (args [0] .toDouble (),
                                                         args [1] .toDouble (),
                                                         args [2] .toDouble (),
                                                         args [3] .toDouble ()))
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
      
      public final func equals (_ vector : SFVec) -> JSValue
      {
         return JSValue (bool: field .wrappedValue == vector .field .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ vector : SFVec)
      {
         field .wrappedValue = vector .field .wrappedValue
      }

      // Functions
      
      public final func add (_ vector : SFVec) -> SFVec
      {
         return SFVec (field: Internal (wrappedValue: field .wrappedValue + vector .field .wrappedValue))
      }

      public final func distance (_ vector : SFVec) -> Scalar
      {
         return simd_distance (field .wrappedValue, vector .field .wrappedValue)
      }

      public final func divide (_ scalar : Scalar) -> SFVec
      {
         return SFVec (field: Internal (wrappedValue: field .wrappedValue / scalar))
      }
      
      public final func divVec (_ vector : SFVec) -> SFVec
      {
         return SFVec (field: Internal (wrappedValue: field .wrappedValue / vector .field .wrappedValue))
      }

      public final func length () -> Scalar
      {
         return simd_length (field .wrappedValue)
      }
      
      public final func lerp (_ vector : SFVec, _ t : Scalar) -> SFVec
      {
         return SFVec (field: Internal (wrappedValue: mix (field .wrappedValue, vector .field .wrappedValue, t: t)))
      }

      public final func multiply (_ scalar : Scalar) -> SFVec
      {
         return SFVec (field: Internal (wrappedValue: field .wrappedValue * scalar))
      }
      
      public final func multVec (_ vector : SFVec) -> SFVec
      {
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

      public final func subtract (_ vector : SFVec) -> SFVec
      {
         return SFVec (field: Internal (wrappedValue: field .wrappedValue - vector .field .wrappedValue))
      }
   }
}
