//
//  X3DPointingDeviceSensorContext.swift
//  X3D
//
//  Created by Holger Seelig on 24.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Cocoa

internal final class X3DPointingDeviceSensorContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate final var selection   = false
   fileprivate final var pointer     = Vector2f .zero
   internal final var enabledSensors = [Set <PointingDeviceSensorContainer>] ()
   
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
   
   internal func mouseMoved (with event : NSEvent)
   {
      let point = browser! .convert (event .locationInWindow, from: nil)
      
      pointer = Vector2f (Float (point .x), Float (point .y)) * Float (browser! .layer! .contentsScale)
      
      browser! .world! .traverse (.Pointer, browser! .renderer)
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

internal protocol X3DPointingDeviceSensorContext : class
{
   var browser                               : X3DBrowser { get }
   var pointingDeviceSensorContextProperties : X3DPointingDeviceSensorContextProperties! { get }
}

extension X3DPointingDeviceSensorContext
{
   internal var selection : Bool
   {
      get { pointingDeviceSensorContextProperties .selection }
      set { pointingDeviceSensorContextProperties .selection = newValue }
   }
   
   internal var pointer : Vector2f { pointingDeviceSensorContextProperties .pointer }
   
   internal func makeHitRay (_ projectionMatrix : Matrix4f, _ viewport : Vector4i)
   {
      let p = ViewVolume .unProjectPoint (pointer .x, pointer .y, 0, .identity, projectionMatrix, viewport)
      
      browser .console .log (pointer, p)
   }
}
