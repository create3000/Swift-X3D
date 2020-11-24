//
//  File.swift
//  
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

@objc internal protocol SFVec3fExports :
   JSExport
{
   var x : Float { get set }
   var y : Float { get set }
   var z : Float { get set }
   
   init ()
   
   func add (_ vector : JavaScript .SFVec3f) -> JavaScript .SFVec3f
   func length () -> Float
   func multiply (_ scalar : Float) -> JavaScript .SFVec3f

   func toString () -> String
}

extension JavaScript
{
   @objc internal final class SFVec3f :
      NSObject,
      SFVec3fExports
   {
      // Properties
      
      public var x : Float { get { object .wrappedValue .x } set { object .wrappedValue .x = newValue } }
      public var y : Float { get { object .wrappedValue .y } set { object .wrappedValue .y = newValue } }
      public var z : Float { get { object .wrappedValue .z } set { object .wrappedValue .z = newValue } }

      // Private properties
      
      private final var object : X3D .SFVec3f
      
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
            self .object = X3D .SFVec3f (wrappedValue: Vector3f (args [0] .toFloat (),
                                                                 args [1] .toFloat (),
                                                                 args [2] .toFloat ()))
         }
         else
         {
            self .object = X3D .SFVec3f ()
         }
      }
      
      required internal init (object : X3D .SFVec3f)
      {
         self .object = object
      }
      
      // Functions
      
      public final func add (_ vector : SFVec3f) -> SFVec3f
      {
         return SFVec3f (object: X3D .SFVec3f (wrappedValue: object .wrappedValue + vector .object .wrappedValue))
      }

      public final func length () -> Float
      {
         return simd_length (object .wrappedValue)
      }
      
      public final func multiply (_ scalar : Float) -> SFVec3f
      {
         return SFVec3f (object: X3D .SFVec3f (wrappedValue: object .wrappedValue * scalar))
      }

      // Input/Output
      
      public final func toString () -> String
      {
         return object .toString ()
      }
   }
}
