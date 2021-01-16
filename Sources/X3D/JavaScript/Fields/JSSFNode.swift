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
   func setProperty (_ name : String, _ value : Any?)
   
   func getNodeTypeName () -> String
   func getNodeName () -> String
   func getNodeType () -> [Int32]
   func getFieldDefinitions () -> [X3DFieldDefinition]

   func toXMLString () -> String
   func toJSONString () -> String
   func toVRMLString () -> String
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

      // Registration
      
      public final override class func register (_ context : JSContext)
      {
         context ["SFNode"] = Self .self
         
         context .evaluateScript ("""
(function (global, Browser, targets)
{
   const Target              = global .SFNode;
   const getProperty         = Target .prototype .getProperty;
   const setProperty         = Target .prototype .setProperty;
   const equals              = Target .prototype .equals;
   const assign              = Target .prototype .assign;
   const getNodeTypeName     = Target .prototype .getNodeTypeName;
   const getNodeName         = Target .prototype .getNodeName;
   const getNodeType         = Target .prototype .getNodeType;
   const getFieldDefinitions = Target .prototype .getFieldDefinitions;
   const toXMLString         = Target .prototype .toXMLString;
   const toJSONString        = Target .prototype .toJSONString;
   const toVRMLString        = Target .prototype .toVRMLString;

   delete Target .prototype .getProperty;
   delete Target .prototype .setProperty;

   Target .prototype .equals = function (array) { return equals .call (targets .get (this), targets .get (array)) }
   Target .prototype .assign = function (array) { return assign .call (targets .get (this), targets .get (array)) }

   Target .prototype .getNodeTypeName     = function () { return getNodeTypeName     .call (targets .get (this)) }
   Target .prototype .getNodeName         = function () { return getNodeName         .call (targets .get (this)) }
   Target .prototype .getNodeType         = function () { return getNodeType         .call (targets .get (this)) }
   Target .prototype .getFieldDefinitions = function () { return getFieldDefinitions .call (targets .get (this)) }
   Target .prototype .toXMLString         = function () { return toXMLString         .call (targets .get (this)) }
   Target .prototype .toJSONString        = function () { return toJSONString        .call (targets .get (this)) }
   Target .prototype .toVRMLString        = function () { return toVRMLString        .call (targets .get (this)) }

   var handler =
   {
      get: function (target, key)
      {
         return targets .get (target) [key];
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

      getFieldDefinitions .call (self) .forEach (function (fieldDefinition)
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
                     native .push ("set_" + fieldDefinition .name)
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
                     nodes .push ("set_" + fieldDefinition .name)
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
                     fields .push ("set_" + fieldDefinition .name)
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
            set: function (newValue) { setProperty .call (self, name, targets .get (newValue)); },
            enumerable: true,
            configurable: false,
         });
      });

      fields .forEach (function (name)
      {
         Object .defineProperty (self, name, {
            get: function () { return getProperty .call (self, Browser, name); },
            set: function (newValue) { setProperty .call (self, name, targets .get (newValue) || newValue); },
            enumerable: true,
            configurable: false,
         });
      });
   }

   function SFNode (object)
   {
      const proxy = new Proxy (this, handler);

      if (object instanceof Target && !targets .get (object))
      {
         var self = object;
      }
      else
      {
         var self = new Target (Browser, ...arguments);
      }

      addFields (self);

      targets .set (this,  self);
      targets .set (proxy, self);

      return proxy;
   }

   SFNode .prototype = Target .prototype;

   DefineProperty (global, "SFNode", SFNode);
})
(this, Browser, targets)
""")
      }
      
      // Construction
      
      required public init ()
      {
         if var args = JSContext .currentArguments () as? [JSValue],
            args .count == 2
         {
            let browser = args .removeFirst () .toObjectOf (X3DBrowser .self) as! X3DBrowser
            
            if let x3dSyntax = args .first! .toString ()
            {
               let scene = try? browser .browser .createX3DFromString (x3dSyntax: x3dSyntax)
               
               self .field = Internal (wrappedValue: scene? .rootNodes .first ?? nil)
               
               browser .browser .scriptingScenes .append (scene)
            }
            else
            {
               self .field = Internal ()
               exception (t("Invalid argument."))
            }
         }
         else
         {
            self .field = Internal ()
            exception (t("Invalid argument."))
         }
         
         super .init (field)
      }
      
      private init (field : Internal)
      {
         self .field = field
         
         super .init (field)
      }
      
      internal static func initWithProxy (_ context : JSContext, field : Internal) -> JSValue!
      {
         return context ["SFNode"]! .construct (withArguments: [SFNode (field: field)])
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
            return JSValue (undefinedIn: JSContext .current ())!
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
      
      public final func setProperty (_ name : String, _ value : Any?)
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
      
      public final func toXMLString () -> String
      {
         if let node = field .wrappedValue
         {
            return node .toXMLString (with: JSContext .current ()! .browser! .executionContext)
         }
         else
         {
            return "NULL"
         }
      }
      
      public final func toJSONString () -> String
      {
         if let node = field .wrappedValue
         {
            return node .toJSONString (with: JSContext .current ()! .browser! .executionContext)
         }
         else
         {
            return "null"
         }
      }

      public final func toVRMLString () -> String
      {
         if let node = field .wrappedValue
         {
            return node .toVRMLString (with: JSContext .current ()! .browser! .executionContext)
         }
         else
         {
            return "NULL"
         }
      }
   }
}
