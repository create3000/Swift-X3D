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
      
      private unowned let browser    : X3DBrowser
      private unowned let scriptNode : Script
      private let context            : JSContext
      
      // Static properties
      
      private static let queue = DispatchQueue (label: "create3000.ecmascript")
      private static let vm    = queue .sync { JSVirtualMachine ()! }

      // Construction
      
      internal init (scriptNode : Script, sourceText : String)
      {
         self .browser    = scriptNode .browser!
         self .scriptNode = scriptNode
         self .context    = JSContext (virtualMachine: Context .vm)!
         
         context .exceptionHandler = { [weak self] in self? .exception ($1) }

         // Register objects and functions.

         register ()

         // Evaluate script source.

         context .evaluateScript (sourceText)
      }
      
      private final func register ()
      {
         // Register objects and functions.

         Global .register (context, browser)
         
         X3DField .register (context)
         
         SFColor     .register (context)
         SFColorRGBA .register (context)
         SFMatrix4f  .register (context)
         SFRotation  .register (context)
         SFVec2d     .register (context)
         SFVec2f     .register (context)
         SFVec3d     .register (context)
         SFVec3f     .register (context)
         SFVec4d     .register (context)
         SFVec4f     .register (context)
      }
      
      private final func exception (_ exception : JSValue?)
      {
         browser .console .error (exception! .toString ())
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
         
         function .call (withArguments: [toValue (field), browser .currentTime])
         
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
   
   internal func fix (_ object : Any)
   {
      // Workaround to fix a bug with indexed properties,
      // where the first accessed indexed property has no setter.
      
      let index : NSString = "9999"
      let value = JSValue (object: object, in: self)
      
      value! .setObject (nil, forKeyedSubscript: index)
      value! .deleteProperty (index)
   }
}
