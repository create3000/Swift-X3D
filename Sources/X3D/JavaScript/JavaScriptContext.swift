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
   internal final class Context
   {
      // Properties
      
      private unowned let browser : X3DBrowser
      private let context         : JSContext
      
      // Static properties
      
      private static let queue = DispatchQueue (label: "create3000.ecmascript")
      private static let vm    = queue .sync { JSVirtualMachine ()! }

      // Construction
      
      internal init (browser : X3DBrowser, script : String)
      {
         self .browser = browser
         self .context = JSContext (virtualMachine: Context .vm)!
         
         context .exceptionHandler = { [weak self] in self? .exception ($1) }
         
         // Register objects and functions.

         register ()
         
         // Evaluate script source.
         
         context .evaluateScript (script)
      }
      
      private final func register ()
      {
         // Register objects and functions.

         JavaScript .Global .register (context, browser)
      }
      
      internal final func initialize ()
      {
         let initialize = context .objectForKeyedSubscript ("initialize")
         
         initialize? .call (withArguments: nil)
      }
      
      private final func exception (_ exception : JSValue?)
      {
         browser .console .error (exception! .toString ())
      }
   }
}

extension JavaScript
{
   internal final class Global
   {
      internal static func register (_ context : JSContext, _ browser : X3DBrowser)
      {
         let print: @convention(block) () -> Void =
         {
            if let args = JSContext .currentArguments () as? [JSValue]
            {
               browser .println (args .map { $0 .toString () } .joined (separator: " "))
            }
         }

         context .setObject (JSValue (nullIn: context), forKeyedSubscript: "NULL"  as NSString)
         context .setObject (false,                     forKeyedSubscript: "FALSE" as NSString)
         context .setObject (true,                      forKeyedSubscript: "TRUE"  as NSString)
         context .setObject (print,                     forKeyedSubscript: "print" as NSString)
      }
   }
}
