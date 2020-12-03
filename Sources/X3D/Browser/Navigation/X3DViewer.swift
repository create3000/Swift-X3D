//
//  X3DViewer.swift
//  X3D
//
//  Created by Holger Seelig on 24.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Cocoa

internal class X3DViewer :
   X3DBaseNode
{
   // Event handlers
   
   internal func mouseDown (with event : NSEvent) { }
   internal func mouseDragged (with event : NSEvent) { }
   internal func mouseUp (with event : NSEvent) { }
   internal func scrollWheel (with event : NSEvent) { }
   internal func render (_ commandBuffer : MTLCommandBuffer) { }

   // Properties
   
   internal final var isActive : Bool = false

   private final var viewportNode : X3DViewportNode
   {
      browser! .world .activeLayerNode! .viewportNode!
   }

   internal final var activeLayer : X3DLayerNode
   {
      browser! .world .activeLayerNode!
   }

   internal final var activeNavigationInfo : NavigationInfo
   {
      browser! .world .activeLayerNode! .navigationInfoNode
   }

   internal final var activeViewpoint : X3DViewpointNode
   {
      browser! .world .activeLayerNode! .viewpointNode
   }
   
   // Operations

   internal final func pointOnCenterPlane (from point : NSPoint) -> Vector3f
   {
      let viewport         = viewportNode .makeRectangle (with: browser!)
      let nearValue        = activeNavigationInfo .nearValue
      let farValue         = activeNavigationInfo .farValue (activeViewpoint)
      let projectionMatrix = activeViewpoint .makeProjectionMatrix (viewport, nearValue, farValue)
      
      // Far plane point
      let scale = browser! .layer! .contentsScale
      let winx  = Float (point .x * scale)
      let winy  = Float (point .y * scale)
      let far   = ViewVolume .unProjectPoint (winx, winy, 0.9, ~projectionMatrix, viewport)
      
      if activeViewpoint is OrthoViewpoint
      {
         return Vector3f (far .x, far .y, -length (distanceToCenter))
      }
      
      let direction = normalize (far)

      return direction * length (distanceToCenter) / dot (direction, -Vector3f .zAxis)
   }
   
   internal var distanceToCenter : Vector3f
   {
      activeViewpoint .userPosition - activeViewpoint .userCenterOfRotation
   }

   internal final func trackballProjectToSphere (from point : NSPoint) -> Vector3f
   {
      let viewport = viewportNode .makeRectangle (with: browser!)
      let scale    = browser! .layer! .contentsScale
      
      let x = (Float (point .x * scale) - Float (viewport [0])) / Float (viewport [2]) - 0.5
      let y = (Float (point .y * scale) - Float (viewport [1])) / Float (viewport [3]) - 0.5
      
      return Vector3f (x, y, tbProjectToSphere (0.5, x, y))
   }

   private final func tbProjectToSphere (_ r : Float, _ x : Float, _ y : Float) -> Float
   {
      let d = sqrt (x * x + y * y)

      if d < r * sqrt (0.5) // Inside sphere
      {
         return sqrt (r * r - d * d)
      }

      // On hyperbola

      let t = r / sqrt (2)
      
      return t * t / d
   }
}
