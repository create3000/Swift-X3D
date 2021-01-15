//
//  X3DConsole.swift
//  X3D
//
//  Created by Holger Seelig on 28.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import OSLog

public enum X3DLogType
{
   case log
   case info
   case warn
   case error
   case code
}

public typealias X3DConsoleInterest = (X3DLogType, String) -> Void

public final class X3DConsole
{
   // Intercept console.
   
   private final var interests = [(id : String, object : AnyObject, requester : X3DConsoleInterest)] ()
   
   public func addInterest <Object : AnyObject> (_ id : String, _ method : @escaping (Object) -> (X3DConsoleInterest), _ object : Object)
   {
      let requester = { [weak object] in method (object!) ($0, $1) }
      
      interests .append ((id, object, requester))
   }
   
   public func removeInterest <Object : AnyObject> (_ id : String, _ method : @escaping (Object) -> (X3DConsoleInterest), _ object : Object)
   {
      interests .removeAll (where: { $0 .id == id && $0 .object === object })
   }

   // Log message.
   
   public final func log (_ message : CustomStringConvertible..., lineBreak : Bool = true)
   {
      dispatch (type: .log, arguments: message, lineBreak: lineBreak)
   }
   
   public final func info (_ message : CustomStringConvertible..., lineBreak : Bool = true)
   {
      dispatch (type: .info, arguments: message, lineBreak: lineBreak)
   }
   
   public final func warn (_ message : CustomStringConvertible..., lineBreak : Bool = true)
   {
      dispatch (type: .warn, arguments: message, lineBreak: lineBreak)
   }
   
   public final func error (_ message : CustomStringConvertible..., lineBreak : Bool = true)
   {
      dispatch (type: .error, arguments: message, lineBreak: lineBreak)
   }

   // Dispatch message.

   private final let osLogTypes : [X3DLogType : OSLogType] = [
      .log   : .debug,
      .info  : .info,
      .warn  : .info,
      .error : .error,
   ]
   
   private final func dispatch (type : X3DLogType, arguments : [CustomStringConvertible], lineBreak : Bool)
   {
      let message = arguments .map { $0 .description } .joined (separator: " ")
      
      #if DEBUG
      os_log (self .osLogTypes [type]!, "%@", message)
      #endif
      
      DispatchQueue .main .async
      {
         for interest in self .interests
         {
            interest .requester (type, message + (lineBreak ? "\n" : ""))
         }
      }
   }
}
