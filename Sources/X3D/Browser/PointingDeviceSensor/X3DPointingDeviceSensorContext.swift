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
   
   internal final var selection         = false
   fileprivate final var pointer        = Vector2f .zero
   fileprivate final var hitRay         = Line3f (point1: .zero, point2: .zero)
   fileprivate final var hits           = [Hit] ()
   fileprivate final var selectedLayer  : X3DLayerNode?
   fileprivate final var enabledSensors = [Set <PointingDeviceSensorContainer>] ()
   private final var overSensors        = Set <PointingDeviceSensorContainer> ()
   private final var activeSensors      = Set <PointingDeviceSensorContainer> ()
   
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
   
   private final var currentCursor : NSCursor = .arrow
   
   private final func setCursor (with event : NSEvent, cursor : NSCursor)
   {
      guard cursor != currentCursor else { return }
      
      currentCursor = cursor
      
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
      guard !browser! .viewerNode .isActive else { return }
      
      // Handle sensors.
      
      pick  (with: event)
      moved (with: event)
   }

   internal func mouseDown (with event : NSEvent)
   {
      // Handle sensors.
      
      pick (with: event)

      if let nearestHit = hits .last
      {
         selectedLayer = nearestHit .layerNode
         activeSensors = nearestHit .sensors ?? [ ]

         activeSensors .forEach { $0 .set_active (active: true, hit: nearestHit) }

         if let sensors = nearestHit .sensors
         {
            if !sensors .isEmpty
            {
               setCursor (with: event, cursor: .closedHand)
               return
            }
         }
      }
      
      // Handle viewer.
      
      browser! .viewerNode .mouseDown (with: event)
      
      setCursor (with: event, cursor: selection ? .arrow : .closedHand)
   }

   internal func mouseDragged (with event : NSEvent)
   {
      // Handle sensors.
      
      mouseMoved (with: event)

      // Handle viewer.
      
      browser! .viewerNode .mouseDragged (with: event)
   }
   
   internal func mouseUp (with event : NSEvent)
   {
      let dummy = Hit (layerNode: nil,
                       layerNumber: 0,
                       shapeNode: nil,
                       pointer: pointer,
                       hitRay: Line3f (point1: .zero, point2: .zero),
                       intersection: Intersection (.zero, .zero, .zero),
                       sensors: nil)
      
      // Handle sensors.
      
      selectedLayer = nil
      
      pick (with: event)
      
      let nearestHit = hits .last

      activeSensors .forEach { $0 .set_active (active: false, hit: nearestHit ?? dummy) }

      activeSensors = [ ]

      // Handle viewer.
      
      browser! .viewerNode .mouseUp (with: event)
      
      setCursor (with: event, cursor: nearestHit? .sensors != nil ? .pointingHand : (selection ? .arrow : .openHand))
   }
   
   internal func mouseExited (with event : NSEvent)
   {
      // Handle sensors.
      
      hits .removeAll (keepingCapacity: true)
      
      moved (with: event)
   }
   
   internal func scrollWheel (with event : NSEvent)
   {
      // Handle viewer.
      
      browser! .viewerNode .scrollWheel (with: event)
   }
   
   // Picking
   
   private func pick (with event : NSEvent)
   {
      let point = browser! .convert (event .locationInWindow, from: nil)
      
      pointer = Vector2f (Float (point .x), Float (point .y)) * Float (browser! .layer! .contentsScale)
      
      hits .removeAll (keepingCapacity: true)
      
      browser! .world! .traverse (.Pointer, browser! .renderer)
      
      hits .sort { $0 .intersection .point .z < $1 .intersection .point .z }
      hits .sort { $0 .layerNumber < $1 .layerNumber }

      browser! .setNeedsDisplay ()
   }
   
   private func moved (with event : NSEvent)
   {
      let nearestHit = hits .last ?? Hit (layerNode: selectedLayer,
                                          layerNumber: 0,
                                          shapeNode: nil,
                                          pointer: pointer,
                                          hitRay: selectedLayer != nil ? hitRay : Line3f (point1: .zero, point2: .zero),
                                          intersection: Intersection (.zero, .zero, .zero),
                                          sensors: nil)
      
      // Set isOver to FALSE for appropriate nodes
      
      let difference = overSensors .subtracting (nearestHit .sensors ?? [ ])
      
      difference .forEach { $0 .set_over (over: false, hit: nearestHit) }
      
      // Set isOver to TRUE for appropriate nodes
      
      overSensors = nearestHit .sensors ?? [ ]
      
      overSensors .forEach { $0 .set_over (over: true, hit: nearestHit) }
      
      // Forward motion event to active drag sensor nodes
      
      activeSensors .forEach { $0 .set_motion (hit: nearestHit) }
      
      // Set cursor.
      
      let cursor : NSCursor = selection
         ? (event .type == .mouseMoved ? .arrow : .closedHand)
         : (event .type == .mouseMoved
               ? (nearestHit .sensors != nil ? .pointingHand : .openHand)
               : .closedHand)
      
      setCursor (with: event, cursor: cursor)
      
      // Update view.
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
   internal var pointer : Vector2f { pointingDeviceSensorContextProperties .pointer }

   internal func pointerInRectangle (_ rectangle : Vector4i) -> Bool
   {
      return pointer .x > Float (rectangle .x) &&
             pointer .x < Float (rectangle .x) + Float (rectangle .z) &&
             pointer .y > Float (rectangle .y) &&
             pointer .y < Float (rectangle .y) + Float (rectangle .w)
   }
   
   internal var sensors : [Set <PointingDeviceSensorContainer>]
   {
      get { pointingDeviceSensorContextProperties .enabledSensors }
      set { pointingDeviceSensorContextProperties .enabledSensors = newValue }
   }

   internal func makeHitRay (_ projectionMatrix : Matrix4f, _ viewport : Vector4i)
   {
      let hitRay = ViewVolume .unProjectRay (pointer .x, pointer .y, .identity, projectionMatrix, viewport)
      
      pointingDeviceSensorContextProperties .hitRay = hitRay
   }
   
   internal var hitRay : Line3f { pointingDeviceSensorContextProperties .hitRay }
   
   internal func addHit (layerNode : X3DLayerNode, layerNumber : Int, shapeNode : X3DShapeNode, intersection : Intersection)
   {
      pointingDeviceSensorContextProperties .hits .append (Hit (
         layerNode:    layerNode,
         layerNumber:  layerNumber,
         shapeNode:    shapeNode,
         pointer:      pointer,
         hitRay:       hitRay,
         intersection: intersection,
         sensors:      pointingDeviceSensorContextProperties .enabledSensors .last
      ))
   }
   
   internal var selectedLayer : X3DLayerNode? { pointingDeviceSensorContextProperties .selectedLayer }
}
