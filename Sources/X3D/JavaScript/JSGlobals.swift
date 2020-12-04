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
this .DefineProperty = function (global, name, value)
{
   Object .defineProperty (global, name, {
      value: value,
      enumerable: true,
      configurable: false,
   });
};

DefineProperty (this, "NULL",  null);
DefineProperty (this, "FALSE", false);
DefineProperty (this, "TRUE",  true);
DefineProperty (this, "print", print);
DefineProperty (this, "trace", trace);
""")
     }
      
      internal class func cleanup (_ context : JSContext)
      {
         context .evaluateScript ("delete this .DefineProperty;")
      }
   }
}
