//
//  File.swift
//  
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol SFRotationExports :
   JSExport
{
   typealias Scalar     = Float
   typealias SFRotation = JavaScript .SFRotation
   typealias SFVec3     = JavaScript .SFVec3f

   var x     : Scalar { get set }
   var y     : Scalar { get set }
   var z     : Scalar { get set }
   var angle : Scalar { get set }

   init ()
   
   func equals (_ rotation : SFRotation) -> JSValue
   func assign (_ rotation : SFRotation)

   func getAxis () -> SFVec3
   func setAxis (_ axis : SFVec3)
   
   func inverse () -> SFRotation
   func multiply (_ rotation : SFRotation) -> SFRotation
   func multVec (_ vector : Any?) -> Any?
   func slerp (_ rotation : SFRotation, _ t : Scalar) -> SFRotation
}

extension JavaScript
{
   @objc internal final class SFRotation :
      X3DField,
      SFRotationExports
   {
      typealias Scalar   = Float
      typealias SFVec3   = SFVec3f
      typealias Internal = X3D .SFRotation
      typealias Inner    = Internal .Value

      // Properties
      
      dynamic public final var x     : Scalar { get { field .wrappedValue .axis .x } set { field .wrappedValue .axis .x = newValue } }
      dynamic public final var y     : Scalar { get { field .wrappedValue .axis .y } set { field .wrappedValue .axis .y = newValue } }
      dynamic public final var z     : Scalar { get { field .wrappedValue .axis .z } set { field .wrappedValue .axis .z = newValue } }
      dynamic public final var angle : Scalar { get { field .wrappedValue .angle }   set { field .wrappedValue .angle   = newValue } }
      
      // Private properties
      
      internal private(set) final var field : Internal

      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFRotation"] = Self .self
         
         context .evaluateScript ("""
Object .defineProperty (SFRotation .prototype, 0, {
   get: function () { return this .x; },
   set: function (newValue) { this .x = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFRotation .prototype, 1, {
   get: function () { return this .y; },
   set: function (newValue) { this .y = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFRotation .prototype, 2, {
   get: function () { return this .z; },
   set: function (newValue) { this .z = newValue; },
   enumerable: true,
   configurable: false,
});
Object .defineProperty (SFRotation .prototype, 3, {
   get: function () { return this .angle; },
   set: function (newValue) { this .angle = newValue; },
   enumerable: true,
   configurable: false,
});
""")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            if args .count == 4
            {
               self .field = Internal (wrappedValue: Inner (args [0] .toFloat (),
                                                            args [1] .toFloat (),
                                                            args [2] .toFloat (),
                                                            args [3] .toFloat ()))
            }
            else if args .count == 2,
                    let from = args [0] .toObjectOf (SFVec3f .self) as? SFVec3f,
                    let to = args [1] .toObjectOf (SFVec3f .self) as? SFVec3f
            {
               self .field = Internal (wrappedValue: Inner (from: from .field .wrappedValue, to: to .field .wrappedValue))
            }
            else if args .count == 2,
                    let axis = args [0] .toObjectOf (SFVec3f .self) as? SFVec3f
            {
               self .field = Internal (wrappedValue: Inner (axis: axis .field .wrappedValue, angle: args [1] .toFloat ()))
            }
            else
            {
               self .field = Internal ()
            }
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
      
      public final func equals (_ rotation : SFRotation) -> JSValue
      {
         return JSValue (bool: field .wrappedValue == rotation .field .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ rotation : SFRotation)
      {
         field .wrappedValue = rotation .field .wrappedValue
      }

      // Property access
      
      public final func getAxis () -> SFVec3
      {
         return SFVec3 (field: X3D .SFVec3f (wrappedValue: field .wrappedValue .axis))
      }
      
      public final func setAxis (_ axis : SFVec3)
      {
         field .wrappedValue .axis = axis .field .wrappedValue
      }

      // Functions
      
      public final func inverse () -> SFRotation
      {
         return SFRotation (field: Internal (wrappedValue: field .wrappedValue .inverse))
      }

      public final func multiply (_ rotation : SFRotation) -> SFRotation
      {
         return SFRotation (field: Internal (wrappedValue: rotation .field .wrappedValue * field .wrappedValue))
      }

      public final func multVec (_ vector : Any?) -> Any?
      {
         if let vector = vector as? SFVec3f
         {
            return SFVec3f (field: SFVec3f .Internal (wrappedValue: field .wrappedValue * vector .field .wrappedValue))
         }
         
         if let vector = vector as? SFVec3d
         {
            return SFVec3d (field: SFVec3d .Internal (wrappedValue: Rotation4d (field .wrappedValue) * vector .field .wrappedValue))
         }
         
         return nil
      }
      
      public final func slerp (_ rotation : SFRotation, _ t : Scalar) -> SFRotation
      {
         return SFRotation (field: Internal (wrappedValue: X3D .slerp (field .wrappedValue, rotation .field .wrappedValue, t: t)))
      }
   }
}
