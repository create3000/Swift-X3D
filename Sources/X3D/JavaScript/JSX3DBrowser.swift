//
//  File.swift
//  
//
//  Created by Holger Seelig on 30.11.20.
//

import JavaScriptCore

@objc internal protocol X3DBrowserFieldExports :
   JSExport
{
   var name             : String { get }
   var version          : String { get }
   var currentSpeed     : Double { get }
   var currentFrameRate : Double { get }
   var description      : String { get set }
   
   func getRenderingProperty (_ name : String) -> Any
   func getBrowserProperty (_ name : String) -> Any
   func getBrowserOption (_ name : String) -> Any
   func setBrowserOption (_ name : String, _ value : Any)
   
   func print ()
   func println ()

   func getName () -> String
   func getVersion () -> String
   func getCurrentSpeed () -> Double
   func getCurrentFrameRate () -> Double
   func getWorldURL () -> String

   func toString () -> String
}

extension JavaScript
{
   @objc internal final class X3DBrowser :
      NSObject,
      X3DBrowserFieldExports
   {
      // Properties
      
      internal unowned let browser          : X3D .X3DBrowser
      internal unowned let executionContext : X3D .X3DExecutionContext

      internal let cache = NSMapTable <X3D .X3DNode, JSValue> (keyOptions: .weakMemory, valueOptions: .strongMemory)
      
      // Construction
      
      internal static func register (_ context : JSContext, _ browser : X3DBrowser)
      {
         context ["X3DBrowser"] = Self .self
         context ["Browser"]    = browser
         
         context .evaluateScript ("""
X3DBrowser .prototype .setDescription = function (newValue) { this .description = newValue; };
""")
      }

      internal init (_ browser : X3D .X3DBrowser, _ executionContext : X3D .X3DExecutionContext)
      {
         self .browser          = browser
         self .executionContext = executionContext
      }
      
      // Properties
      
      dynamic public final var name             : String { browser .getName () }
      dynamic public final var version          : String { browser .getVersion () }
      dynamic public final var currentSpeed     : Double { browser .getCurrentSpeed () }
      dynamic public final var currentFrameRate : Double { browser .getCurrentFrameRate () }
      
      dynamic public final override var description : String
      {
         get { browser .getDescription () }
         set { browser .setDescription (newValue) }
      }

      // print
      
      public final func print ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            browser .print (args .map { $0 .toString () ?? "" } .joined (separator: " "))
         }
      }
      
      public final func println ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            browser .println (args .map { $0 .toString () ?? "" } .joined (separator: " "))
         }
      }
      
      func getRenderingProperty (_ name : String) -> Any
      {
         guard let field = try? browser .getRenderingProperties () .getField (name: name) else
         {
            return JSValue (undefinedIn: JSContext .current ())!
         }
         
         return JavaScript .getValue (JSContext .current (), self, field)
      }
      
      func getBrowserProperty (_ name : String) -> Any
      {
         guard let field = try? browser .getBrowserProperties () .getField (name: name) else
         {
            return JSValue (undefinedIn: JSContext .current ())!
         }
         
         return JavaScript .getValue (JSContext .current (), self, field)
      }
      
      func getBrowserOption (_ name : String) -> Any
      {
         guard let field = try? browser .getBrowserOptions () .getField (name: name) else
         {
            return JSValue (undefinedIn: JSContext .current ())!
         }
         
         return JavaScript .getValue (JSContext .current (), self, field)
      }
      
      func setBrowserOption (_ name : String, _ value : Any)
      {
         guard let field = try? browser .getBrowserOptions () .getField (name: name) else
         {
            return
         }
         
         JavaScript .setValue (field, value)
      }

      // VRML
      
      public final func getName () -> String
      {
         return browser .getName ()
      }
      
      public final func getVersion () -> String
      {
         return browser .getVersion ()
      }
      
      public final func getCurrentSpeed () -> Double
      {
         return browser .getCurrentSpeed ()
      }
      
      public final func getCurrentFrameRate () -> Double
      {
         return browser .getCurrentFrameRate ()
      }
      
      public final func getWorldURL () -> String
      {
         return executionContext .getWorldURL () .absoluteURL .description
      }

      // Input/Output
      
      public final func toString () -> String
      {
         return "[object X3DBrowser]"
      }
   }
}
