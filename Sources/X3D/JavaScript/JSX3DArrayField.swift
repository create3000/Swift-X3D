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
this .X3DArrayFieldWrapper = function (global, Browser, targets, CLASS)
{
   const Target    = global [CLASS];
   const get1Value = Target .prototype .get1Value;
   const set1Value = Target .prototype .set1Value;

   delete Target .prototype .get1Value;
   delete Target .prototype .set1Value;

   function getMethod (self, method)
   {
      return function ()
      {
         for (var i = 0, length = arguments .length; i < length; ++ i)
         {
            arguments [i] = targets .get (arguments [i]) || arguments [i];
         }

         return method .apply (self, arguments);
      };
   }

   var handler =
   {
      get: function (target, key)
      {
         const self = targets .get (target);

         try
         {
            const index = key * 1;

            if (Number .isInteger (index) && index >= 0)
            {
               return get1Value .call (self, Browser, index);
            }
            else
            {
               const value = self [key];

               if (typeof value == "function")
                  return getMethod (self, value);

               return value;
            }
         }
         catch (error)
         {
            // Catch symbol error.

            const value = self [key];

            if (typeof value == "function")
               return getMethod (self, value);

            return value;
         }
      },
      set: function (target, key, value)
      {
         const self = targets .get (target);

         try
         {
            const index = key * 1;

            if (Number .isInteger (index) && index >= 0)
            {
               set1Value .call (self, index, targets .get (value) || value);
            }
            else
            {
               self [key] = value;
            }

            return true;
         }
         catch (error)
         {
            // Catch symbol error.

            self [key] = value;
            return true;
         }
      },
      has: function (target, key)
      {
         if (Number .isInteger (key * 1))
            return key < target .length;

         return key in targets .get (target);
      },
   };

   function MFArray (object)
   {
      const proxy = new Proxy (this, handler);

      if (object instanceof Target && !targets .get (object))
      {
         var self = object;
      }
      else
      {
         for (var i = 0, length = arguments .length; i < length; ++ i)
         {
            arguments [i] = targets .get (arguments [i]) || arguments [i];
         }

         var self = new Target (...arguments);
      }

      targets .set (this,  self);
      targets .set (proxy, self);

      return proxy;
   }

   MFArray .prototype = Target .prototype;

   global [CLASS] = MFArray;

   return MFArray;
}
""")
      }
      
      internal final class func cleanup (_ context : JSContext)
      {
         context .evaluateScript ("delete this .X3DArrayFieldWrapper;")
      }
   }
}
