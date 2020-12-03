//
//  File.swift
//  
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

extension JavaScript
{
   internal final class Globals
   {
      internal static func register (_ context : JSContext, _ browser : X3D .X3DBrowser)
      {
         let print : @convention(block) () -> Void =
         {
            [weak browser] in
            
            if let args = JSContext .currentArguments () as? [JSValue]
            {
               browser? .println (args .map { $0 .toString () ?? "" } .joined (separator: " "))
            }
         }
         
         context ["print"] = print
         context ["trace"] = print
         
         context .evaluateScript("""
(function (global)
{
   Object .defineProperty (global, "NULL", {
      value: null,
      enumerable: true,
      configurable: false,
   });
   Object .defineProperty (global, "FALSE", {
      value: false,
      enumerable: true,
      configurable: false,
   });
   Object .defineProperty (global, "TRUE", {
      value: true,
      enumerable: true,
      configurable: false,
   });
})
(this)
""")
     }
   }
}
