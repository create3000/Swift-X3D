//
//  JSSFNode.swift
//
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

@objc internal protocol SFNodeExports :
   JSExport
{
   typealias SFNode = JavaScript .SFNode

   init ()
   
   func equals (_ color : SFNode) -> JSValue
   func assign (_ color : SFNode)
   
   func getProperty (_ name : String) -> Any
   func setProperty (_ name : String, _ value : Any) -> Bool
   
   func getNodeTypeName () -> String
   func getNodeName () -> String
   func getNodeType () -> [Int32]
   //func getFieldDefinitions () -> FieldDefinitionArray

   func toVRMLString () -> String
   func toXMLString () -> String
}

extension JavaScript
{
   @objc internal final class SFNode :
      X3DField,
      SFNodeExports
   {
      typealias Internal = X3D .SFNode <X3D .X3DNode>
      typealias Inner    = Internal .Value
      
      // Private properties
      
      internal private(set) final var object : Internal

      // Registration
      
      private static var proxy : JSValue!
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFNode"] = Self .self
         
         context .evaluateScript ("""
(function (global, targets)
{
   const Target      = global .SFNode;
   const getProperty = Target .prototype .getProperty;
   const setProperty = Target .prototype .setProperty;

   delete Target .prototype .getProperty;
   delete Target .prototype .setProperty;

   function getMethod (target, method)
   {
      return function ()
      {
         for (var i = 0, length = arguments .length; i < length; ++ i)
         {
            arguments [i] = targets .get (arguments [i]) || arguments [i];
         }

         return method .apply (target, arguments);
      };
   }

   var handler =
   {
      get: function (target, key)
      {
         const self = targets .get (target);

         try
         {
            const value = self [key];

            if (value !== undefined)
            {
               if (typeof value == "function")
                  return getMethod (self, value);

               return value;
            }

            return getProperty .call (self, key);
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

         if (!setProperty .call (self, key, targets .get (value) || value))
         {
            self [key] = value;
         }

         return true;
      },
      has: function (target, key)
      {
         return key in targets .get (target);
      },
   };

   function SFNode ()
   {
      const target = new Target (...arguments);
      const self   = new Proxy (this, handler);

      targets .set (this, target);
      targets .set (self, target);

      return self;
   }

   SFNode .prototype = Target .prototype;

   global .SFNode = SFNode;
})
(this, targets)
""")
         
         proxy = context .evaluateScript ("SFNode;")
      }
      
      // Construction
      
      required public init ()
      {
         if let args = JSContext .currentArguments () as? [JSValue], args .count == 1
         {
            if let node = args .first! .toObjectOf (SFNode .self) as? SFNode
            {
               self .object = Internal (wrappedValue: node .object .wrappedValue)
            }
            else
            {
               self .object = Internal ()
            }
         }
         else
         {
            self .object = Internal ()
         }
         
         super .init (object)
      }
      
      internal init (object : Internal)
      {
         self .object = object
         
         super .init (object)
      }
      
      internal static func initWithProxy (object : Internal) -> JSValue!
      {
         return proxy .construct (withArguments: [SFNode (object: object)])
      }

      // Common operators
      
      public final func equals (_ node : SFNode) -> JSValue
      {
         return JSValue (bool: object .wrappedValue === node .object .wrappedValue, in: JSContext .current ())
      }
      
      public final func assign (_ node : SFNode)
      {
         object .wrappedValue = node .object .wrappedValue
      }
      
      // Properties
      
      public final func getProperty (_ name : String) -> Any
      {
         if let node = object .wrappedValue
         {
            if let field = try? node .getField (name: name),
               field .getAccessType () != .inputOnly
            {
               return JavaScript .getValue (JSContext .current (), field)
            }
            else
            {
               return JSValue (undefinedIn: JSContext .current ())!
            }
         }
         else
         {
            return JSValue (nullIn: JSContext .current ())!
         }
      }
      
      public final func setProperty (_ name : String, _ value : Any) -> Bool
      {
         if let node = object .wrappedValue
         {
            if let field = try? node .getField (name: name),
               field .getAccessType () != .outputOnly
            {
               JavaScript .setValue (field, value)
               return true
            }
         }
         
         return false
      }
      
      public final func getNodeTypeName () -> String
      {
         return object .wrappedValue? .getTypeName () ?? "X3DNode"
      }
      
      public final func getNodeName () -> String
      {
         return object .wrappedValue? .getName () ?? ""
      }
      
      public final func getNodeType () -> [Int32]
      {
         return object .wrappedValue? .getType () .map { $0 .rawValue } ?? [ ]
      }
      
      // public final func getFieldDefinitions () -> FieldDefinitionArray

      public final func toVRMLString () -> String
      {
         return object .wrappedValue? .toString () ?? ""
      }
      
      public final func toXMLString () -> String
      {
         return object .wrappedValue? .toString () ?? ""
      }
   }
}
