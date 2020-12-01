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
   internal static func error <T : Any> (_ message : String) -> T?
   {
      JSContext .current ()! .exception = JSValue (newErrorFromMessage: message, in: JSContext .current ())
      return nil
   }
   
   internal static func error (_ message : String)
   {
      JSContext .current ()! .exception = JSValue (newErrorFromMessage: message, in: JSContext .current ())
   }
}
