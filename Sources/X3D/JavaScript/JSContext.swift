//
//  File.swift
//  
//
//  Created by Holger Seelig on 23.11.20.
//

import JavaScriptCore

internal class JavaScript { }

extension JavaScript
{   
   internal final class Context :
      X3D .X3DInputOutput
   {
      // Properties
      
      private unowned let scriptNode : X3D .Script
      private let browser            : X3DBrowser
      private let context            : JSContext
      
      // Static properties
      
      private static let queue = DispatchQueue (label: "create3000.ecmascript")
      private static let vm    = queue .sync { JSVirtualMachine ()! }

      // Construction
      
      internal init (scriptNode : X3D .Script, sourceText : String)
      {
         self .scriptNode = scriptNode
         self .browser    = X3DBrowser (scriptNode .browser!, scriptNode .executionContext!)
         self .context    = JSContext (virtualMachine: Context .vm)!
         
         // Add exception handler.
         
         context .exceptionHandler = { [weak self] in self? .exception ($1) }

         // Register objects and functions.

         register ()

         // Evaluate script source.

         context .evaluateScript (sourceText)
      }
      
      private final func register ()
      {
         // Add hidden objects.
         
         context .evaluateScript ("this .targets = new WeakMap ();")

         // Register objects and functions.
         
         Globals    .register (context, scriptNode .browser!)
         X3DBrowser .register (context, browser)
         
         X3DConstants       .register (context)
         X3DFieldDefinition .register (context)

         X3DField      .register (context)
         X3DArrayField .register (context)

         SFColor     .register (context)
         SFColorRGBA .register (context)
         SFImage     .register (context)
         SFMatrix3d  .register (context)
         SFMatrix3f  .register (context)
         SFMatrix4d  .register (context)
         SFMatrix4f  .register (context)
         SFRotation  .register (context)
         SFVec2d     .register (context)
         SFVec2f     .register (context)
         SFVec3d     .register (context)
         SFVec3f     .register (context)
         SFVec4d     .register (context)
         SFVec4f     .register (context)
         
         SFNode      .register (context)

         MFBool      .register (context)
         MFDouble    .register (context)
         MFFloat     .register (context)
         MFInt32     .register (context)
         MFString    .register (context)
         MFTime      .register (context)
         
         MFColor     .register (context)
         MFColorRGBA .register (context)
         MFImage     .register (context)
         MFMatrix3d  .register (context)
         MFMatrix3f  .register (context)
         MFMatrix4d  .register (context)
         MFMatrix4f  .register (context)
         MFRotation  .register (context)
         MFVec2d     .register (context)
         MFVec2f     .register (context)
         MFVec3d     .register (context)
         MFVec3f     .register (context)
         MFVec4d     .register (context)
         MFVec4f     .register (context)
         
         MFNode      .register (context)

         X3DArrayField .cleanup (context)

         // Add user-defined fields to global object.
         
         let getProperty : @convention(block) (X3DBrowser, String) -> Any =
         {
            [weak self] in JavaScript .getValue (self! .context, $0, try! self! .scriptNode .getField (name: $1))
         }
         
         let setProperty : @convention(block) (String, Any) -> Void =
         {
            [weak self] in JavaScript .setValue (try! self! .scriptNode .getField (name: $0), $1)
         }

         context ["getProperty"] = getProperty
         context ["setProperty"] = setProperty
         
         var native = [String] ()
         var nodes  = [String] ()
         var fields = [String] ()

         for field in scriptNode .getUserDefinedFields ()
         {
            switch field .getType ()
            {
               case .SFBool, .SFDouble, .SFFloat, .SFInt32, .SFString, .SFTime: do
               {
                  switch field .getAccessType ()
                  {
                     case .inputOnly:
                        break
                     case .inputOutput:
                        native .append (field .getName () + "_changed")
                        fallthrough
                     case .initializeOnly, .outputOnly:
                        native .append (field .getName ())
                  }
               }
               case .SFNode: do
               {
                  switch field .getAccessType ()
                  {
                     case .inputOnly:
                        break
                     case .inputOutput:
                        nodes .append (field .getName () + "_changed")
                        fallthrough
                     case .initializeOnly, .outputOnly:
                        nodes .append (field .getName ())
                  }
               }
               default: do
               {
                  switch field .getAccessType ()
                  {
                     case .inputOnly:
                        break
                     case .inputOutput:
                        fields .append (field .getName () + "_changed")
                        fallthrough
                     case .initializeOnly, .outputOnly:
                        fields .append (field .getName ())
                  }
               }
            }
         }
         
         context .evaluateScript ("""
(function (global, targets)
{
   delete global .targets;

   const getProperty = global .getProperty;
   const setProperty = global .setProperty;

   delete global .getProperty;
   delete global .setProperty;

   ["\(native .joined (separator: "\",\""))"] .forEach (function (name)
   {
      if (!name) return;

      Object .defineProperty (global, name, {
         get: function () { return getProperty (Browser, name); },
         set: function (newValue) { setProperty (name, newValue); },
         enumerable: true,
         configurable: false,
      });
   });

   ["\(nodes .joined (separator: "\",\""))"] .forEach (function (name)
   {
      if (!name) return;

      Object .defineProperty (global, name, {
         get: function () { return getProperty (Browser, name); },
         set: function (newValue) { setProperty (name, targets .get (newValue) || null); },
         enumerable: true,
         configurable: false,
      });
   });

   ["\(fields .joined (separator: "\",\""))"] .forEach (function (name)
   {
      if (!name) return;

      const value = getProperty (Browser, name);

      if (value instanceof X3DArrayField)
      {
         Object .defineProperty (global, name, {
            get: function () { return value; },
            set: function (newValue) { setProperty (name, targets .get (newValue)); },
            enumerable: true,
            configurable: false,
         });
      }
      else
      {
         Object .defineProperty (global, name, {
            get: function () { return value; },
            set: function (newValue) { setProperty (name, newValue); },
            enumerable: true,
            configurable: false,
         });
      }
   });
})(this, targets);
""")
      }
      
      private final func exception (_ exception : JSValue?)
      {
         let stacktrace = exception! .objectForKeyedSubscript ("stack")! .toString ()! .replacingOccurrences (of: "\n", with: " ")
         let lineNumber = exception! .objectForKeyedSubscript ("line")! .toInt32 ()
         let column     = exception! .objectForKeyedSubscript ("column")! .toInt32 ()
         
         scriptNode .browser! .console .error ("""
# JavaScript error at line \(lineNumber), \(column):
# in Script '\(scriptNode .getName ())' url '\(scriptNode .executionContext! .getWorldURL () .absoluteURL .description)'
# in method \(stacktrace).
#
# \(exception!)
""")
      }
      
      internal final func initialize ()
      {
         if context .evaluateScript ("typeof initialize == 'function'")! .toBool ()
         {
            context ["initialize"]! .call (withArguments: nil)
         }
         
         scriptNode .scene! .$isLive .addInterest ("set_live", Context .set_live, self)
         
         set_live ()
      }
      
      private final func set_live ()
      {
         let browser = scriptNode .browser!
         
         if scriptNode .scene! .isLive || scriptNode .executionContext! .getType () .contains (.X3DPrototypeInstance)
         {
            if context .evaluateScript ("typeof prepareEvents == 'function'")! .toBool ()
            {
               prepareEventsFunction = context ["prepareEvents"]

               browser .addBrowserInterest (event: .Browser_Event, id: "prepareEvents", method: Context .prepareEvents, object: self)
            }

            if context .evaluateScript ("typeof eventsProcessed == 'function'")! .toBool ()
            {
               eventsProcessedFunction = context ["eventsProcessed"]

               scriptNode .addInterest ("eventsProcessed", Context .eventsProcessed, self)
            }
            
            for field in scriptNode .getUserDefinedFields ()
            {
               switch field .getAccessType ()
               {
                  case .inputOnly: do
                  {
                     guard context .evaluateScript ("typeof \(field .getName ()) == 'function'")! .toBool () else { break }
                     
                     let function : JSValue? = self .context [field .getName ()]
                     
                     field .addInterest ("set_field", { _ in { [weak self, weak field] in self? .set_field (field, function) } }, self)
                  }
                  case .inputOutput: do
                  {
                     guard context .evaluateScript ("typeof set_\(field .getName ()) == 'function'")! .toBool () else { break }
                     
                     let function : JSValue? = self .context ["set_" + field .getName ()]
                     
                     field .addInterest ("set_field", { _ in { [weak self, weak field] in self? .set_field (field, function) } }, self)
                  }
                  default:
                     break
               }
            }
         }
         else
         {
            browser .removeBrowserInterest (event: .Browser_Event, id: "prepareEvents", method: Context .prepareEvents, object: self)
            
            scriptNode .removeInterest ("eventsProcessed", Context .eventsProcessed, self)
            
            for field in scriptNode .getUserDefinedFields ()
            {
               field .removeInterest ("set_field", { _ in { } }, self)
            }
         }
      }
      
      private final var prepareEventsFunction : JSValue?
      
      private final func prepareEvents ()
      {
         prepareEventsFunction! .call (withArguments: nil)
      }
      
      private final func set_field (_ field : X3D .X3DField?, _ function : JSValue?)
      {
         guard let field = field, let function = function else { return }
         
         field .isTainted = true
         
         function .call (withArguments: [getValue (context, browser, field), scriptNode .browser! .currentTime])
         
         field .isTainted = false
      }
      
      private final var eventsProcessedFunction : JSValue?

      private final func eventsProcessed ()
      {
         eventsProcessedFunction! .call (withArguments: nil)
      }

      deinit
      {
         if context .evaluateScript ("typeof shutdown == 'function'")! .toBool ()
         {
            context ["shutdown"]! .call (withArguments: nil)
         }
      }
   }
}

extension JSContext
{
   internal subscript (_ key : String) -> JSValue?
   {
      get { return objectForKeyedSubscript (key as NSString) }
   }

   internal subscript (_ key : String) -> Any?
   {
      get { return objectForKeyedSubscript (key) }
      set { setObject (newValue, forKeyedSubscript: key as NSString) }
   }
   
   private static let fixindex : NSString = "9999"
   
   internal func fix (_ object : Any)
   {
      // Workaround to fix a bug with indexed properties,
      // where the first accessed indexed property has no setter.
      
      let value = JSValue (object: object, in: self)
      
      value! .setObject (nil, forKeyedSubscript: JSContext .fixindex)
      value! .deleteProperty (JSContext .fixindex)
   }
}
