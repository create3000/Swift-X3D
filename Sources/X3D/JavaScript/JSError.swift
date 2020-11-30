//
//  File.swift
//  
//
//  Created by Holger Seelig on 30.11.20.
//

import JavaScriptCore

extension JavaScript
{
   internal static func error (_ message : String) -> Any?
   {
      guard let browser = JSContext .current () .objectForKeyedSubscript ("Browser")? .toObjectOf (X3DBrowser .self) as? X3DBrowser else
      {
         return nil
      }
      
      browser .browser .console .error ("ECMAScript error:", message)
      
      return nil
   }
}
