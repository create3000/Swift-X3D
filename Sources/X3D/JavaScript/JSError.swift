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
   internal static func error (_ message : String) -> Any?
   {
      JSContext .current ()! .exception = JSValue (newErrorFromMessage: message, in: JSContext .current ())
      return nil
   }
}
