//
//  X3DLightingContext.swift
//  X3D
//
//  Created by Holger Seelig on 26.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DLightingContextProperties :
   X3DBaseNode
{
   // Properties
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
   }
}

internal protocol X3DLightingContext : class
{
   var browser                   : X3DBrowser { get }
   var lightingContextProperties : X3DLightingContextProperties! { get }
}

extension X3DLightingContext { }
