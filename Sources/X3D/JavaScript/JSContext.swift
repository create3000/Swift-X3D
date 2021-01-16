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
      
      private weak var scriptNode : X3D .Script?
      private let context         : JSContext
      private var browser         : X3DBrowser!
      
      // Static properties
      
      private static let vm = JSVirtualMachine ()!

      // Construction
      
      internal init (scriptNode : X3D .Script, sourceText : String)
      {
         self .scriptNode = scriptNode
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
         guard let browser          = scriptNode? .browser,
               let executionContext = scriptNode? .executionContext else
         { return }
         
         // Add hidden objects.
         
         context .evaluateScript ("this .targets = new WeakMap ();")
         
         self .browser = X3DBrowser (context, browser, executionContext)

         // Register objects and functions.
         
         Globals                   .register (context, browser)
         X3DBrowser                .register (context, self .browser)
         X3DScene                  .register (context)
         X3DExecutionContext       .register (context)
         ProfileInfo               .register (context)
         ComponentInfo             .register (context)
         X3DProtoDeclaration       .register (context)
         X3DExternProtoDeclaration .register (context)
         X3DRoute                  .register (context)

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
         Globals       .cleanup (context)

         // Add user-defined fields to global object.
         
         let getProperty : @convention(block) (String) -> Any =
         {
            [weak self] in JavaScript .getValue (self! .context, self! .browser, try! self! .scriptNode! .getField (name: $0))
         }
         
         let setProperty : @convention(block) (String, Any?) -> Void =
         {
            [weak self] in JavaScript .setValue (try! self! .scriptNode! .getField (name: $0), $1)
         }

         context ["getProperty"] = getProperty
         context ["setProperty"] = setProperty
         
         var native = [String] ()
         var nodes  = [String] ()
         var fields = [String] ()

         for field in scriptNode! .getUserDefinedFields ()
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
         get: function () { return getProperty (name); },
         set: function (newValue) { setProperty (name, newValue); },
         enumerable: true,
         configurable: false,
      });
   });

   ["\(nodes .joined (separator: "\",\""))"] .forEach (function (name)
   {
      if (!name) return;

      Object .defineProperty (global, name, {
         get: function () { return getProperty (name); },
         set: function (newValue) { setProperty (name, targets .get (newValue)); },
         enumerable: true,
         configurable: false,
      });
   });

   ["\(fields .joined (separator: "\",\""))"] .forEach (function (name)
   {
      if (!name) return;

      Object .defineProperty (global, name, {
         get: function () { return getProperty (name); },
         set: function (newValue) { setProperty (name, targets .get (newValue) || newValue); },
         enumerable: true,
         configurable: false,
      });
   });
})(this, targets);
""")
      }
      
      private final func exception (_ exception : JSValue?)
      {
         let stacktrace = exception! .objectForKeyedSubscript ("stack")! .toString ()! .replacingOccurrences (of: "\n", with: " ")
         let lineNumber = exception! .objectForKeyedSubscript ("line")! .toInt32 ()
         let column     = exception! .objectForKeyedSubscript ("column")! .toInt32 ()
         let url        = scriptNode! .executionContext! .getWorldURL () .absoluteString
         
         scriptNode! .browser! .console .error ("""
JavaScript error at line \(lineNumber), \(column):
in Script named '\(scriptNode! .getName ())' in file '\(url)'
in method \(stacktrace).

\(exception!)
""")
      }
      
      @discardableResult
      internal final func evaluateScript (_ script : String) -> String
      {
         context .evaluateScript (script) .toString ()
      }

      internal final func initialize ()
      {
         guard let scene = scriptNode! .scene else { return }
         
         if context .evaluateScript ("typeof initialize == 'function'")! .toBool ()
         {
            context ["initialize"]! .call (withArguments: nil)
         }
         
         scene .$isLive .addInterest ("set_live", Context .set_live, self)
         
         set_live ()
      }
      
      private final func set_live ()
      {
         guard let browser          = scriptNode? .browser,
               let scene            = scriptNode? .scene,
               let executionContext = scriptNode? .executionContext
         else { return }
         
         if scene .isLive || executionContext .getType () .contains (.X3DPrototypeInstance)
         {
            if context .evaluateScript ("typeof prepareEvents == 'function'")! .toBool ()
            {
               prepareEventsFunction = context ["prepareEvents"]

               browser .addBrowserInterest (event: .Browser_Event, id: "prepareEvents", method: Context .prepareEvents, object: self)
            }

            if context .evaluateScript ("typeof eventsProcessed == 'function'")! .toBool ()
            {
               eventsProcessedFunction = context ["eventsProcessed"]

               scriptNode! .addInterest ("eventsProcessed", Context .eventsProcessed, self)
            }
            
            for field in scriptNode! .getUserDefinedFields ()
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
            
            scriptNode! .removeInterest ("eventsProcessed", Context .eventsProcessed, self)
            
            for field in scriptNode! .getUserDefinedFields ()
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
         
         function .call (withArguments: [getValue (context, browser, field), scriptNode! .browser! .currentTime])
         
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
      get { return objectForKeyedSubscript (key) }
   }

   internal subscript (_ key : String) -> Any?
   {
      get { return objectForKeyedSubscript (key) }
      set { setObject (newValue, forKeyedSubscript: key as NSString) }
   }
   
   internal var browser : JavaScript .X3DBrowser?
   {
      return objectForKeyedSubscript ("Browser")? .toObjectOf (JavaScript .X3DBrowser .self) as? JavaScript .X3DBrowser
   }
   
   internal func target (_ value : JSValue) -> JSValue?
   {
      browser? .targets .call (withArguments: [value])
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
