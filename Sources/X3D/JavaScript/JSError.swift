//
//  File.swift
//  
//
//  Created by Holger Seelig on 30.11.20.
//

import JavaScriptCore

extension JavaScript
{
   @discardableResult
   internal static func exception <T : Any> (_ message : String) -> T?
   {
      exception (message)
      return nil
   }
   
   internal static func exception (_ message : String)
   {
      JSContext .current ()! .exception = JSValue (newErrorFromMessage: message, in: JSContext .current ())
   }
}
