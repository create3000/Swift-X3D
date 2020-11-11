//
//  X3DPointingDeviceSensorContext.swift
//  X3D
//
//  Created by Holger Seelig on 24.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Cocoa

typealias Intersection = (texCoord : Vector4f, normal : Vector3f, point : Vector3f)

internal final class X3DPointingDeviceSensorContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate final var selection   = false
   fileprivate final var pointer     = Vector2f .zero
   fileprivate final var hitRay      = Line3f (point1: .zero, point2: .zero)
   internal final var enabledSensors = [Set <PointingDeviceSensorContainer>] ()
   fileprivate final var hits        = [Hit] ()
   
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
      pick (with: event)
      
      guard let nearestHit = hits .last else { return }
      
      browser! .console .log (nearestHit .intersection .point)
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
   
   // Picking
   
   private func pick (with event : NSEvent)
   {
      //guard !browser! .viewerNode .isActive else { return }
      
      let point = browser! .convert (event .locationInWindow, from: nil)
      
      pointer = Vector2f (Float (point .x), Float (point .y)) * Float (browser! .layer! .contentsScale)
      
      hits .removeAll (keepingCapacity: true)
      
      browser! .world! .traverse (.Pointer, browser! .renderer)
      
      hits .sort { $0 .intersection .point .z < $1 .intersection .point .z }
      hits .sort { $0 .layerNumber < $1 .layerNumber }

      browser! .setNeedsDisplay ()
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
      let hitRay = ViewVolume .unProjectRay (pointer .x, pointer .y, .identity, projectionMatrix, viewport)
      
      pointingDeviceSensorContextProperties .hitRay = hitRay
   }
   
   internal var hitRay : Line3f { pointingDeviceSensorContextProperties .hitRay }
   
   internal func addHit (layerNode : X3DLayerNode, layerNumber : Int, shapeNode : X3DShapeNode, modelMatrix : Matrix4f, intersection : Intersection)
   {
      pointingDeviceSensorContextProperties .hits .append (Hit (
         layerNode:    layerNode,
         layerNumber:  layerNumber,
         shapeNode:    shapeNode,
         pointer:      pointer,
         hitRay:       hitRay,
         modelMatrix:  modelMatrix,
         intersection: intersection,
         sensors:      pointingDeviceSensorContextProperties .enabledSensors .last
      ))
   }
}
