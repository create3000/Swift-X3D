//
//  X3DCoreContext.swift
//  X3D
//
//  Created by Holger Seelig on 08.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

internal final class X3DCoreContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate final var browserOptions      : BrowserOptions
   fileprivate final var browserProperties   : BrowserProperties
   fileprivate final var renderingProperties : RenderingProperties

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      self .browserOptions      = BrowserOptions      (with: executionContext)
      self .browserProperties   = BrowserProperties   (with: executionContext)
      self .renderingProperties = RenderingProperties (with: executionContext)
      
      super .init (executionContext .browser!, executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      browserOptions      .setup ()
      browserProperties   .setup ()
      renderingProperties .setup ()
   }
   
   private final var nodeDefinitions = [String : X3DNode] ()
   
   fileprivate func getNodeDefinition (typeName : String) -> X3DNode
   {
      if let nodeDefinition = nodeDefinitions [typeName]
      {
         return nodeDefinition
      }
      else
      {
         let nodeDefinition = try! executionContext! .createNode (typeName: typeName, setup: false)
         
         nodeDefinitions [typeName] = nodeDefinition
         
         return nodeDefinition
      }
   }
}

internal protocol X3DCoreContext : class
{
   var browser               : X3DBrowser { get }
   var coreContextProperties : X3DCoreContextProperties! { get }
}

extension X3DCoreContext
{
   internal var browserOptions      : BrowserOptions { coreContextProperties .browserOptions }
   internal var browserProperties   : BrowserProperties { coreContextProperties .browserProperties }
   internal var renderingProperties : RenderingProperties { coreContextProperties .renderingProperties }
   
   internal var browserQueue : DispatchQueue { DispatchQueue .global (qos: .userInteractive) }
   internal var inlineQueue  : DispatchQueue { DispatchQueue .global (qos: .userInitiated) }
   internal var imageQueue   : DispatchQueue { DispatchQueue .global (qos: .utility) }
   internal var fontQueue    : DispatchQueue { DispatchQueue .global (qos: .utility) }
   internal var shaderQueue  : DispatchQueue { DispatchQueue .global (qos: .utility) }
   
   internal func getNodeDefinition (typeName : String) -> X3DNode
   {
      return coreContextProperties .getNodeDefinition (typeName: typeName)
   }
}
