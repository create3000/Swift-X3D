//
//  File.swift
//  
//
//  Created by Holger Seelig on 11.12.20.
//

import JavaScriptCore

@objc internal protocol X3DComponentInfoExports :
   JSExport
{
   var title       : String { get }
   var name        : String { get }
   var level       : Int32 { get }
   var providerUrl : String { get }
   
   func toString () -> String
}

extension JavaScript
{
   @objc internal class ComponentInfo :
      NSObject,
      X3DComponentInfoExports
   {
      // Registration
      
      internal static func register (_ context : JSContext)
      {
         context ["ComponentInfo"] = Self .self
      }
      
      // Construction
      
      private final var componentInfo : X3D .ComponentInfo
      
      internal init (_ componentInfo : X3D .ComponentInfo)
      {
         self .componentInfo = componentInfo
      }
      
      // Property access
      
      dynamic public var title       : String { componentInfo .title }
      dynamic public var name        : String { componentInfo .name }
      dynamic public var level       : Int32 { componentInfo .level }
      dynamic public var providerUrl : String { componentInfo .providerUrl }

      // Input/Output
      
      public final func toString () -> String
      {
         return "[object ComponentInfo]"
      }
   }
}
