//
//  X3DLayeringContext.swift
//  X3D
//
//  Created by Holger Seelig on 07.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DLayeringContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate private(set) var defaultViewportNode : Viewport

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      self .defaultViewportNode = Viewport (with: executionContext)

      super .init (executionContext .browser!, executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      defaultViewportNode .setup ()
   }
}

internal protocol X3DLayeringContext : AnyObject
{
   var browser                   : X3DBrowser { get }
   var layeringContextProperties : X3DLayeringContextProperties! { get }
}

extension X3DLayeringContext
{
   internal var defaultViewportNode : Viewport { layeringContextProperties .defaultViewportNode }
}
