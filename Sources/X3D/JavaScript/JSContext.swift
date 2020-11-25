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
         
         SFVec2d .register (context)
         SFVec2f .register (context)
         SFVec3d .register (context)
         SFVec3f .register (context)
         SFVec4d .register (context)
         SFVec4f .register (context)
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
      }
      
      private final var prepareEventsFunction : JSValue?
      
      private final func prepareEvents ()
      {
         prepareEventsFunction! .call (withArguments: nil)
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
   internal subscript (_ key : NSString) -> JSValue?
   {
      get { return objectForKeyedSubscript (key) }
   }

   internal subscript(_ key : NSString) -> Any?
   {
      get { return objectForKeyedSubscript (key) }
      set { setObject (newValue, forKeyedSubscript: key) }
   }
}
