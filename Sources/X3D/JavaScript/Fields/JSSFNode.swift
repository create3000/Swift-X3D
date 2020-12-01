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
   typealias SFNode             = JavaScript .SFNode
   typealias X3DFieldDefinition = JavaScript .X3DFieldDefinition
   typealias X3DBrowser         = JavaScript .X3DBrowser

   init ()
   
   func equals (_ node : SFNode) -> Any
   //func assign (_ node : SFNode)
   
   func getProperty (_ browser : X3DBrowser, _ name : String) -> Any
   func setProperty (_ name : String, _ value : Any)
   
   func getNodeTypeName () -> String
   func getNodeName () -> String
   func getNodeType () -> [Int32]
   func getFieldDefinitions () -> [X3DFieldDefinition]

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
      
      internal private(set) final var field : Internal
      private final var scene : X3DScene?

      // Registration
      
      private static var proxy : JSValue!
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFNode"] = Self .self
         
         context .evaluateScript ("""
(function (global, Browser, targets)
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
         const self  = targets .get (target);
         const value = self [key];

         if (typeof value == "function")
            return getMethod (self, value);

         return value;
      },
      set: function (target, key, value)
      {
         targets .get (target) [key] = value;
         return true;
      },
      has: function (target, key)
      {
         return key in targets .get (target);
      },
   };

   function addFields (self)
   {
      const native = [ ];
      const nodes  = [ ];
      const fields = [ ];

      self .getFieldDefinitions () .forEach (function (fieldDefinition)
      {
         switch (fieldDefinition .dataType)
         {
            case X3DConstants .SFBool:
            case X3DConstants .SFDouble:
            case X3DConstants .SFFloat:
            case X3DConstants .SFInt32:
            case X3DConstants .SFString:
            case X3DConstants .SFTime:
            {
               switch (fieldDefinition .accessType)
               {
                  case X3DConstants .inputOutput:
                     native .push (fieldDefinition .name + "_changed")
                  case X3DConstants .initializeOnly:
                  case X3DConstants .inputOnly:
                  case X3DConstants .outputOnly:
                     native .push (fieldDefinition .name)
               }

               break;
            }
            case X3DConstants .SFNode:
            {
               switch (fieldDefinition .accessType)
               {
                  case X3DConstants .inputOutput:
                     nodes .push (fieldDefinition .name + "_changed")
                  case X3DConstants .initializeOnly:
                  case X3DConstants .inputOnly:
                  case X3DConstants .outputOnly:
                     nodes .push (fieldDefinition .name)
               }

               break;
            }
            default:
            {
               switch (fieldDefinition .accessType)
               {
                  case X3DConstants .inputOutput:
                     fields .push (fieldDefinition .name + "_changed")
                  case X3DConstants .initializeOnly:
                  case X3DConstants .inputOnly:
                  case X3DConstants .outputOnly:
                     fields .push (fieldDefinition .name)
               }

               break;
            }
         }
      });

      native .forEach (function (name)
      {
         Object .defineProperty (self, name, {
            get: function () { return getProperty .call (self, Browser, name); },
            set: function (newValue) { setProperty .call (self, name, newValue); },
            enumerable: true,
            configurable: false,
         });
      });

      nodes .forEach (function (name)
      {
         Object .defineProperty (self, name, {
            get: function () { return getProperty .call (self, Browser, name); },
            set: function (newValue) { setProperty .call (self, name, targets .get (newValue) || null); },
            enumerable: true,
            configurable: false,
         });
      });

      fields .forEach (function (name)
      {
         const value = getProperty .call (self, Browser, name);

         if (value instanceof X3DArrayField)
         {
            Object .defineProperty (self, name, {
               get: function () { return value; },
               set: function (newValue) { setProperty .call (self, name, targets .get (newValue)); },
               enumerable: true,
               configurable: false,
            });
         }
         else
         {
            Object .defineProperty (self, name, {
               get: function () { return value; },
               set: function (newValue) { setProperty .call (self, name, newValue); },
               enumerable: true,
               configurable: false,
            });
         }
      });
   }

   function SFNode ()
   {
      const proxy = new Proxy (this, handler);
      const self  = new Target (Browser, proxy, ...arguments);

      addFields (self);

      targets .set (this,  self);
      targets .set (proxy, self);

      return proxy;
   }

   SFNode .prototype = Target .prototype;

   global .SFNode = SFNode;
})
(this, Browser, targets)
""")
         
         proxy = context .evaluateScript ("SFNode;")
      }
      
      // Construction
      
      required public init ()
      {
         if var args = JSContext .currentArguments () as? [JSValue],
            args .count == 3
         {
            let browser = args .removeFirst () .toObjectOf (X3DBrowser .self) as! X3DBrowser
            let proxy   = args .removeFirst ()
            
            if let node = args .first! .toObjectOf (SFNode .self) as? SFNode
            {
               self .field = Internal (wrappedValue: node .field .wrappedValue)
            }
            else if let x3dSyntax = args .first! .toString ()
            {
               self .scene = try? browser .browser .createX3DFromString (x3dSyntax: x3dSyntax)
               self .field = Internal (wrappedValue: scene? .rootNodes .first ?? nil)
               
               browser .cache .setObject (proxy, forKey: field .wrappedValue)
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
      }
      
      internal init (field : Internal)
      {
         self .field = field
         
         super .init (field)
      }
      
      internal static func initWithProxy (field : Internal) -> JSValue!
      {
         return proxy .construct (withArguments: [SFNode (field: field)])
      }

      // Common operators
      
      public final func equals (_ node : SFNode) -> Any
      {
         field .wrappedValue === node .field .wrappedValue
      }
      
      //public final func assign (_ node : SFNode)
      //{
      //   field .wrappedValue = node .field .wrappedValue
      //}
      
      // Properties
      
      public final func getProperty (_ browser : X3DBrowser, _ name : String) -> Any
      {
         guard let node = field .wrappedValue else
         {
            return JSValue (nullIn: JSContext .current ())!
         }
         
         if let field = try? node .getField (name: name),
            field .getAccessType () != .inputOnly
         {
             return JavaScript .getValue (JSContext .current (), browser, field)
         }
         else
         {
            return JSValue (undefinedIn: JSContext .current ())!
         }
      }
      
      public final func setProperty (_ name : String, _ value : Any)
      {
         guard let node = field .wrappedValue else { return }
         
         if let field = try? node .getField (name: name),
            field .getAccessType () != .outputOnly
         {
            JavaScript .setValue (field, value)
         }
      }
      
      public final func getNodeTypeName () -> String
      {
         return field .wrappedValue? .getTypeName () ?? "X3DNode"
      }
      
      public final func getNodeName () -> String
      {
         return field .wrappedValue? .getName () ?? ""
      }
      
      public final func getNodeType () -> [Int32]
      {
         return field .wrappedValue? .getType () .map { $0 .rawValue } ?? [ ]
      }
      
      public final func getFieldDefinitions () -> [X3DFieldDefinition]
      {
         var fieldDefinitions = [X3DFieldDefinition] ()
         
         if let node = field .wrappedValue
         {
            for field in node .getFieldDefinitions ()
            {
               fieldDefinitions .append (X3DFieldDefinition (accessType: Int32 (field .getAccessType () .rawValue),
                                                             dataType: field .getType () .rawValue,
                                                             name: field .getName ()))
            }
         }
         
         return fieldDefinitions
      }

      public final func toVRMLString () -> String
      {
         return field .wrappedValue? .toString () ?? ""
      }
      
      public final func toXMLString () -> String
      {
         return field .wrappedValue? .toString () ?? ""
      }
   }
}
