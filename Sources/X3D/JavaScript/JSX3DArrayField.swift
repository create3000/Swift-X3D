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
this .MakeX3DArrayField = function (global, targets, native, CLASS)
{
   const Target    = global [CLASS];
   const get1Value = Target .prototype .get1Value;
   const set1Value = Target .prototype .set1Value;
   const equals    = Target .prototype .equals;
   const assign    = Target .prototype .assign;
   
   delete Target .prototype .get1Value;
   delete Target .prototype .set1Value;

   Target .prototype .equals = function (array) { return equals .call (targets .get (this), targets .get (array)) }
   Target .prototype .assign = function (array) { return assign .call (targets .get (this), targets .get (array)) }

   Target .prototype .push = function ()
   {
      const self = targets .get (this);
      let   l    = self .length;

      if (native)
      {
         for (let i = 0, length = arguments .length; i < length; ++ i)
            set1Value .call (self, l + i, arguments [i]);
      }
      else
      {
         for (let i = 0, length = arguments .length; i < length; ++ i)
            set1Value .call (self, l + i, targets .get (arguments [i]));
      }

      return self .length;
   };
   
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
               return get1Value .call (self, index);
            }
            else
            {
               return self [key];
            }
         }
         catch (error)
         {
            // Catch symbol error.

            return self [key];
         }
      },
      set: (native ? function (target, key, value)
      {
         const self = targets .get (target);

         try
         {
            const index = key * 1;

            if (Number .isInteger (index) && index >= 0)
            {
               set1Value .call (self, index, value);
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
      } : function (target, key, value)
      {
         const self = targets .get (target);

         try
         {
            const index = key * 1;

            if (Number .isInteger (index) && index >= 0)
            {
               set1Value .call (self, index, targets .get (value));
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
      }),
      has: function (target, key)
      {
         if (Number .isInteger (key * 1))
            return key < target .length;

         return key in targets .get (target);
      },
   };

   function MFNativeArray (object)
   {
      const proxy = new Proxy (this, handler);

      if (object instanceof Target && !targets .get (object))
      {
         var self = object;
      }
      else
      {
         var self = new Target (...arguments);
      }

      targets .set (this,  self);
      targets .set (proxy, self);

      return proxy;
   }

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

   MFNativeArray .prototype = Target .prototype;
   MFArray       .prototype = Target .prototype;

   DefineProperty (global, CLASS, native ? MFNativeArray : MFArray)
};
""")
      }
      
      internal final class func cleanup (_ context : JSContext)
      {
         context .evaluateScript ("delete this .MakeX3DArrayField;")
      }
   }
}
