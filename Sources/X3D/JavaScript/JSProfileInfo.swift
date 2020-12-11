//
//  File.swift
//  
//
//  Created by Holger Seelig on 11.12.20.
//

import JavaScriptCore

@objc internal protocol X3DProfileInfoExports :
   JSExport
{
   typealias ComponentInfo = JavaScript .ComponentInfo
   
   var name        : String { get }
   var title       : String { get }
   var providerUrl : String { get }
   var components  : [ComponentInfo] { get }
   
   func toString () -> String
}

extension JavaScript
{
   @objc internal class ProfileInfo :
      NSObject,
      X3DProfileInfoExports
   {
      // Registration
      
      internal static func register (_ context : JSContext)
      {
         context ["ProfileInfo"] = Self .self
      }
      
      // Construction
      
      private final var profile : X3D .ProfileInfo
      
      internal init (_ profile : X3D .ProfileInfo)
      {
         self .profile = profile
      }
      
      // Property access

      dynamic public var name        : String { profile .name }
      dynamic public var title       : String { profile .title }
      dynamic public var providerUrl : String { profile .providerUrl }
      dynamic public var components  : [ComponentInfo] { profile .components .map { ComponentInfo ($0) } }

      // Input/Output
      
      public final func toString () -> String
      {
         return "[object ProfileInfo]"
      }
   }
}
