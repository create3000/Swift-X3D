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
      internal static func register (_ context : JSContext, _ browser : X3DBrowser)
      {
         let print : @convention(block) () -> Void =
         {
            [weak browser] in
            
            if let args = JSContext .currentArguments () as? [JSValue]
            {
               browser? .println (args .map { $0 .toString () ?? "" } .joined (separator: " "))
            }
         }
         
         context ["NULL"]  = JSValue (nullIn: context)
         context ["FALSE"] = false
         context ["TRUE"]  = true
         context ["print"] = print
         context ["trace"] = print
     }
   }
}
