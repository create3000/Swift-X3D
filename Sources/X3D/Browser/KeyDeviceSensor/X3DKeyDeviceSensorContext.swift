//
//  X3DKeyDeviceSensorContext.swift
//  X3D
//
//  Created by Holger Seelig on 16.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Cocoa

internal final class X3DKeyDeviceSensorContextProperties :
   X3DBaseNode
{
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
   
   internal final func keyDown (with event : NSEvent)
   {
      //debugPrint (#function, event)
   }
   
   internal final func keyUp (with event : NSEvent)
   {
      //debugPrint (#function, event)
   }
}

internal protocol X3DKeyDeviceSensorContext : class
{
   var browser                          : X3DBrowser { get }
   var keyDeviceSensorContextProperties : X3DKeyDeviceSensorContextProperties! { get }
}

extension X3DKeyDeviceSensorContext { }
