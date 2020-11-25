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
   
   func multiply (_ rotation : SFRotation) -> SFRotation
   func multVec (_ vector : SFVec3) -> SFVec3
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
      
      dynamic public var x     : Scalar { get { object .wrappedValue .axis .x } set { object .wrappedValue .axis .x = newValue } }
      dynamic public var y     : Scalar { get { object .wrappedValue .axis .y } set { object .wrappedValue .axis .y = newValue } }
      dynamic public var z     : Scalar { get { object .wrappedValue .axis .z } set { object .wrappedValue .axis .z = newValue } }
      dynamic public var angle : Scalar { get { object .wrappedValue .angle }   set { object .wrappedValue .angle   = newValue } }
      
      // Private properties
      
      internal private(set) final var object : Internal
      
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
      }
      
      required internal init (object : Internal)
      {
         self .object = object
         
         super .init (self .object)
      }

      // Common operators
      
      public final func equals (_ rotation : SFRotation) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == rotation .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ rotation : SFRotation)
      {
         object .wrappedValue = rotation .object .wrappedValue
      }

      // Functions
      
      public final func getAxis () -> SFVec3
      {
         return SFVec3 (object: X3D .SFVec3f (wrappedValue: object .wrappedValue .axis))
      }
      
      public final func setAxis (_ axis : SFVec3)
      {
         object .wrappedValue .axis = axis .object .wrappedValue
      }

      public final func multiply (_ rotation : SFRotation) -> SFRotation
      {
         return SFRotation (object: Internal (wrappedValue: rotation .object .wrappedValue * object .wrappedValue))
      }

      public final func multVec (_ vector : SFVec3) -> SFVec3
      {
         return SFVec3 (object: SFVec3 .Internal (wrappedValue: object .wrappedValue * vector .object .wrappedValue))
      }
      
      public final func slerp (_ rotation : SFRotation, _ t : Scalar) -> SFRotation
      {
         return SFRotation (object: Internal (wrappedValue: X3D .slerp (object .wrappedValue, rotation .object .wrappedValue, t: t)))
      }
   }
}
