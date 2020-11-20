//
//  File.swift
//  
//
//  Created by Holger Seelig on 17.11.20.
//

import Cocoa

internal class X3DFlyViewer :
   X3DViewer
{
   // Properties
   
   private final var fromVector : Vector3f = .zero
   private final var toVector   : Vector3f = .zero
   private final var direction  : Vector3f = .zero
   private final var startTime  : TimeInterval = 0
   
   // Static properties
   
   private static let SPEED_FACTOR          : Float = 0.007
   private static let SHIFT_SPEED_FACTOR    : Float = 4 * SPEED_FACTOR
   private static let ROTATION_SPEED_FACTOR : Float = 1.4
   private static let ROTATION_LIMIT        : Float = 40

   // Event handlers
   
   internal final override func mouseDown (with event : NSEvent)
   {
      disconnect ()
      activeViewpoint .transitionStop ()
      
      isActive = true
      
      browser! .addCollision (object: self)
      browser! .setNeedsDisplay ()
      
      if event .modifierFlags .contains (NSEvent .ModifierFlags .option)
      {
         // Look around.
         fromVector = trackballProjectToSphere (from: browser! .convert (event .locationInWindow, from: nil))
      }
      else
      {
         // Move.
         let point = browser! .convert (event .locationInWindow, from: nil)
         
         fromVector = Vector3f (Float (point .x), 0, Float (-point .y))
         toVector   = fromVector
         
         if browser! .getBrowserOptions () .Rubberband
         {
            browser! .addBrowserInterest (event: .Browser_Done, id: "move", method: X3DFlyViewer .move, object: self)
         }
      }
   }
   
   private final var shift : Bool = false
   
   internal final override func mouseDragged (with event : NSEvent)
   {
      shift = event .modifierFlags .contains (NSEvent .ModifierFlags .shift)
      
      if event .modifierFlags .contains (NSEvent .ModifierFlags .option)
      {
         // Look around.
         var orientation = activeViewpoint .userOrientation
         let toVector    = trackballProjectToSphere (from: browser! .convert (event .locationInWindow, from: nil))

         orientation = orientation * Rotation4f (from: toVector, to: fromVector)
         orientation = activeViewpoint .straightenHorizon (orientation) * orientation

         activeViewpoint .orientationOffset = orientation * ~activeViewpoint .orientation

         fromVector = toVector
      }
      else
      {
         // Fly.
         let point = browser! .convert (event .locationInWindow, from: nil)
         
         toVector  = Vector3f (Float (point .x), 0, Float (-point .y))
         direction = toVector - fromVector

         addFly ()
      }
   }
   
   internal final override func mouseUp (with event : NSEvent)
   {
      disconnect ()

      isActive = false

      browser! .removeCollision (object: self)
      browser! .setNeedsDisplay ()
   }
   
   internal final override func scrollWheel (with event : NSEvent)
   {
      
   }
   
   private final func fly ()
   {
      let now      = browser! .currentTime
      let dt       = Float (now - startTime)
      let upVector = activeViewpoint .upVector

      // Rubberband values

      let up = Rotation4f (from: .yAxis, to: upVector)

      let rubberBandRotation = direction .z > 0
                               ? Rotation4f (from: up * direction, to: up * .zAxis)
                               : Rotation4f (from: up * -.zAxis, to: up * direction)

      let rubberBandLength = length (direction)

      // Position offset

      var speedFactor = 1 - rubberBandRotation .angle / (.pi / 2)

      speedFactor *= activeNavigationInfo .speed
      speedFactor *= activeViewpoint .getSpeedFactor ()
      speedFactor *= shift ? X3DFlyViewer .SHIFT_SPEED_FACTOR : X3DFlyViewer .SPEED_FACTOR
      speedFactor *= dt

      let translation = getTranslationOffset (speedFactor * direction)

      activeViewpoint .positionOffset += browser! .collider .constrain (translation)
      
      // Rotation

      var weight = X3DFlyViewer .ROTATION_SPEED_FACTOR * dt

      weight *= pow (rubberBandLength / (rubberBandLength + X3DFlyViewer .ROTATION_LIMIT), 2)

      activeViewpoint .orientationOffset = slerp (.identity, rubberBandRotation, t: weight) * activeViewpoint .orientationOffset

      // GeoRotation

      let geoRotation = Rotation4f (from: upVector, to: activeViewpoint .upVector)

      activeViewpoint .orientationOffset = geoRotation * activeViewpoint .orientationOffset

      startTime = now
   }
   
   private final func move ()
   {
      
   }

   private final func addFly ()
   {
      startTime = browser! .currentTime
      
      browser! .addBrowserInterest (event: .Browser_Done, id: "fly", method: X3DFlyViewer .fly, object: self)
      browser! .setNeedsDisplay ()
   }
   
   internal func getTranslationOffset (_ translation : Vector3f) -> Vector3f { return .zero }

   private final func disconnect ()
   {
      browser! .removeBrowserInterest (event: .Browser_Done, id: "move", method: X3DFlyViewer .move, object: self)
      browser! .removeBrowserInterest (event: .Browser_Done, id: "fly",  method: X3DFlyViewer .fly,  object: self)
   }
}
