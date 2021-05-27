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
      //browser! .console .log (#function, event .keyCode)
      
      switch event .keyCode
      {
         case KeyCodes .home:
            browser! .firstViewpoint ()
         case KeyCodes .pageUp:
            browser! .previousViewpoint ()
         case KeyCodes .pageDown:
            browser! .nextViewpoint ()
         case KeyCodes .end:
            browser! .lastViewpoint ()
         default:
            break
      }
   }
   
   internal final func keyUp (with event : NSEvent)
   {
      //browser! .console .log (#function, event)
   }
}

internal protocol X3DKeyDeviceSensorContext : AnyObject
{
   var browser                          : X3DBrowser { get }
   var keyDeviceSensorContextProperties : X3DKeyDeviceSensorContextProperties! { get }
}

extension X3DKeyDeviceSensorContext { }
