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
   
   @SFNode fileprivate final var browserOptions      : BrowserOptions?
   @SFNode fileprivate final var browserProperties   : BrowserProperties?
   @SFNode fileprivate final var renderingProperties : RenderingProperties?

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
      
      browserOptions      = BrowserOptions      (with: executionContext!)
      browserProperties   = BrowserProperties   (with: executionContext!)
      renderingProperties = RenderingProperties (with: executionContext!)
   }
}

internal protocol X3DCoreContext : class
{
   var browser               : X3DBrowser { get }
   var coreContextProperties : X3DCoreContextProperties! { get }
}

extension X3DCoreContext
{
   internal var browserOptions      : BrowserOptions { coreContextProperties .browserOptions! }
   internal var browserProperties   : BrowserProperties { coreContextProperties .browserProperties! }
   internal var renderingProperties : RenderingProperties { coreContextProperties .renderingProperties! }
   
   internal var browserQueue : DispatchQueue { DispatchQueue .global (qos: .userInteractive) }
   internal var inlineQueue  : DispatchQueue { DispatchQueue .global (qos: .userInitiated) }
   internal var imageQueue   : DispatchQueue { DispatchQueue .global (qos: .utility) }
   internal var fontQueue    : DispatchQueue { DispatchQueue .global (qos: .utility) }
   internal var shaderQueue  : DispatchQueue { DispatchQueue .global (qos: .utility) }
}
