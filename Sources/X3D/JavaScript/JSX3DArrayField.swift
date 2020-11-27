//
//  JSX3DArrayField.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol X3DArrayFieldExports :
   JSExport
{ }

extension JavaScript
{
   @objc internal class X3DArrayField :
      X3DField,
      X3DArrayFieldExports
   {
      // Registration
      
      internal override class func register (_ context : JSContext)
      {
         context ["X3DArrayField"] = Self .self
         
         context .evaluateScript ("""
this .X3DNativeArray = function (global, CLASS)
{
   const Target = global [CLASS];

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

   function MFArray (object)
   {
      if (object instanceof Target && !object .self)
      {
         var target = object;
      }
      else
      {
         var target = new Target (...arguments);
      }

      target .self = target;

      return new Proxy (target, handler);
   }

   global [CLASS] = MFArray;

   return MFArray;
}
""")
      }
      
      internal final class func cleanup (_ context : JSContext)
      {
         context ["X3DArrayField"] = Self .self
         
         context .evaluateScript ("delete this .NativeArray;")
      }

      // Construction
      
      internal init (_ object : X3D .X3DArrayField)
      {
         super .init (object)
      }
   }
}
