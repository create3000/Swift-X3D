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
   
   @SFNode fileprivate private(set) var defaultViewportNode : Viewport?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addChildObjects ($defaultViewportNode)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      defaultViewportNode = Viewport (with: executionContext!)

      defaultViewportNode! .setup ()
   }
}

internal protocol X3DLayeringContext : class
{
   var browser                   : X3DBrowser { get }
   var layeringContextProperties : X3DLayeringContextProperties! { get }
}

extension X3DLayeringContext
{
   internal var defaultViewportNode : Viewport { layeringContextProperties .defaultViewportNode! }
}
