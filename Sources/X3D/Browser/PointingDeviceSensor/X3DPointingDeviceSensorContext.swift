//
//  X3DPointingDeviceSensorContext.swift
//  X3D
//
//  Created by Holger Seelig on 24.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Cocoa

public final class X3DPointingDeviceSensorContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate final var selection = false
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
   }
   
   // Cursor handling
   
   private final func setCursor (with event : NSEvent, cursor : NSCursor)
   {
      browser! .discardCursorRects ()
      browser! .addCursorRect (browser! .bounds, cursor: cursor)
      browser! .cursorUpdate (with: event)
   }

   // Event handler
   
   internal func mouseEntered (with event : NSEvent)
   {
      setCursor (with: event, cursor: selection ? .arrow : .openHand)
   }
   
   internal func mouseDown (with event : NSEvent)
   {
      browser! .viewerNode .mouseDown (with: event)
      
      setCursor (with: event, cursor: selection ? .arrow : .closedHand)
   }

   internal func mouseDragged (with event : NSEvent)
   {
      browser! .viewerNode .mouseDragged (with: event)
   }
   
   internal func mouseUp (with event : NSEvent)
   {
      browser! .viewerNode .mouseUp (with: event)
      
      setCursor (with: event, cursor: selection ? .arrow : .openHand)
   }
   
   internal func mouseExited (with event : NSEvent)
   {
   }
   
   internal func scrollWheel (with event : NSEvent)
   {
      browser! .viewerNode .scrollWheel (with: event)
   }
}

public protocol X3DPointingDeviceSensorContext : class
{
   var browser                               : X3DBrowser { get }
   var pointingDeviceSensorContextProperties : X3DPointingDeviceSensorContextProperties! { get }
}

extension X3DPointingDeviceSensorContext
{
   public var selection : Bool
   {
      get { pointingDeviceSensorContextProperties .selection }
      set { pointingDeviceSensorContextProperties .selection = newValue }
   }
}
