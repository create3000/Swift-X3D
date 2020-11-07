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
   
   @SFNode fileprivate final var browserOptions      : X3DBrowserOptions?
   @SFNode fileprivate final var browserProperties   : X3DBrowserProperties?
   @SFNode fileprivate final var renderingProperties : X3DRenderingProperties?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addChildObjects ($browserOptions,
                       $browserProperties,
                       $renderingProperties)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      browserOptions      = X3DBrowserOptions      (with: executionContext!)
      browserProperties   = X3DBrowserProperties   (with: executionContext!)
      renderingProperties = X3DRenderingProperties (with: executionContext!)
   }
}

internal protocol X3DCoreContext : class
{
   var browser               : X3DBrowser { get }
   var coreContextProperties : X3DCoreContextProperties! { get }
}

extension X3DCoreContext
{
   internal var name    : String { "Sunrise X3D Browser" }
   internal var version : String { "1.0" }
   
   internal var supportedProfiles   : [String : X3DProfileInfo] { X3DSupportedProfiles .profiles }
   internal var supportedComponents : [String : X3DComponentInfo] { X3DSupportedComponents .components }
   internal var supportedNodes      : [String : X3DNodeInterface .Type] { X3DSupportedNodes .nodes }
   internal var supportedFields     : [String : X3DFieldInterface .Type] { X3DSupportedFields .fields }
   internal var browserOptions      : X3DBrowserOptions { coreContextProperties .browserOptions! }
   internal var browserProperties   : X3DBrowserProperties { coreContextProperties .browserProperties! }
   internal var renderingProperties : X3DRenderingProperties { coreContextProperties .renderingProperties! }
   
   internal var browserQueue : DispatchQueue { DispatchQueue .global (qos: .userInteractive) }
   internal var inlineQueue  : DispatchQueue { DispatchQueue .global (qos: .userInitiated) }
   internal var imageQueue   : DispatchQueue { DispatchQueue .global (qos: .utility) }
   internal var fontQueue    : DispatchQueue { DispatchQueue .global (qos: .utility) }
}
