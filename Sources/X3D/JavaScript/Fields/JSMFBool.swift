//
//  JSMFBool.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol MFBoolExports :
   JSExport
{
   typealias Scalar = Bool
   typealias MFBool = JavaScript .MFBool
   
   var length : Int { get set }
   
   init ()
   
   func equals (_ array : MFBool) -> JSValue
   func assign (_ array : MFBool)

   func get1Value (_ index : Int) -> JSValue
   func set1Value (_ index : Int, _ value : Scalar)
}

extension JavaScript
{
   @objc internal class MFBool :
      X3DArrayField,
      MFBoolExports
   {
      typealias Scalar   = Bool
      typealias Internal = X3D .MFBool
      
      // Properties
      
      dynamic public var length : Int
      {
         get { object .wrappedValue .count }
         set { object .wrappedValue .resize (newValue, fillWith: Scalar ()) }
      }

      // Private properties
      
      internal private(set) final var object : Internal
      
      // Registration
      
      internal override class func register (_ context : JSContext)
      {
         context ["MFBool"] = Self .self
         
         context .evaluateScript ("""
(function (global)
{
   const Target = global .MFBool;

   function getMethod (target, method)
   {
      return function ()
      {
         for (var i = 0, length = arguments .length; i < length; ++ i)
         {
            if (arguments [i] instanceof X3DArrayField)
            {
               arguments [i] = arguments [i] .self;
            }
         }

         return method .apply (target, arguments);
      };
   }

   var handler =
   {
      get: function (target, key)
      {
         try
         {
            const index = key * 1;

            if (Number .isInteger (index) && index >= 0)
            {
               return target .get1Value (index);
            }
            else
            {
               const value = target [key];

               if (typeof value == "function")
                  return getMethod (target, value);

               return value;
            }
         }
         catch (error)
         {
            // Catch symbol error.

            const value = target [key];

            if (typeof value == "function")
               return getMethod (target, value);

            return value;
         }
      },
      set: function (target, key, value)
      {
         try
         {
            const index = key * 1;

            if (Number .isInteger (index) && index >= 0)
            {
               target .set1Value (index, value);
            }
            else
            {
               target [key] = value;
            }

            return true;
         }
         catch (error)
         {
            // Catch symbol error.

            target [key] = value;
            return true;
         }
      },
      has: function (target, key)
      {
         if (Number .isInteger (key * 1))
            return key < target .length;

         return key in target;
      },
      enumerate: function (target)
      {
         const indices = [ ];

         for (var i = 0, length = target .length; i < length; ++ i)
            array .push (i);

         return indices [Symbol .iterator] ();
      },
   };

   function MFBool ()
   {
      const target = new Target (...arguments);

      target .self = target;

      return new Proxy (target, handler);
   }

   global .MFBool = MFBool;

})(this)
""")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            self .object = Internal (wrappedValue: args .map { $0 .toBool () })
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
      
      public final func equals (_ array : MFBool) -> JSValue
      {
         return JSValue (bool: object .wrappedValue == array .object .wrappedValue, in: JSContext .current ())
      }

      public final func assign (_ array : MFBool)
      {
         object .wrappedValue = array .object .wrappedValue
      }

      // Property access
      
      public final func get1Value (_ index : Int) -> JSValue
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: Scalar ())
         }
         
         return JSValue (bool: object .wrappedValue [index], in: JSContext .current ())
      }
      
      public final func set1Value (_ index : Int, _ value : Scalar)
      {
         if index >= object .wrappedValue .count
         {
            object .wrappedValue .resize (index + 1, fillWith: Scalar ())
         }
         
         object .wrappedValue [index] = value
      }
   }
}
