//
//  File.swift
//  
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

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
               browser .println (args .map { $0 .toString () ?? "" } .joined (separator: " "))
            }
         }
         
         let null = JSValue (nullIn: context)
         
         context .setObject (null,  forKeyedSubscript: "NULL"  as NSString)
         context .setObject (false, forKeyedSubscript: "FALSE" as NSString)
         context .setObject (true,  forKeyedSubscript: "TRUE"  as NSString)
         context .setObject (print, forKeyedSubscript: "print" as NSString)
         context .setObject (print, forKeyedSubscript: "trace" as NSString)
      }
   }
}
