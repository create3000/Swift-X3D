//
//  X3DExamineViewer.swift
//  X3D
//
//  Created by Holger Seelig on 25.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Cocoa

internal final class ExamineViewer :
   X3DViewer
{
   // Constants
   
   private final let FRAME_RATE        : TimeInterval = 60
   private final let MOTION_TIME       : TimeInterval = 0.05
   private final let SPIN_RELEASE_TIME : TimeInterval = 0.02
   private final let SPIN_ANGLE        : Float = 0.006
   private final let SPIN_FACTOR       : Float = 0.8
   private final let SCROLL_FACTOR     : Float = 1.0 / 120.0
   private final let MAX_ANGLE         : Float = 0.97

   // Properties
   
   private final var mouseMode  = 0
   private final var fromVector = Vector3f .zero
   private final var fromPoint  = Vector3f .zero
   private final var rotation   = Rotation4f .identity
   private final var downTime   = TimeInterval (0)
   private final var motionTime = TimeInterval (0)
   

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
   
   // Event handlers
      
   internal final override func mouseDown (with event : NSEvent)
   {
      isActive = true
      
      if event .modifierFlags .isEmpty
      {
         removeSpinning ()
         
         activeViewpoint .transitionStop ()

         mouseMode  = 1
         fromVector = trackballProjectToSphere (from: browser! .convert (event .locationInWindow, from: nil))
         rotation   = Rotation4f .identity
         downTime   = SFTime .now
         motionTime = 0
      }
      
      else if event .modifierFlags .contains (NSEvent .ModifierFlags .option)
      {
         removeSpinning ()
         
         activeViewpoint .transitionStop ()
         
         mouseMode = 2
         fromPoint = pointOnCenterPlane (from: browser! .convert (event .locationInWindow, from: nil))
      }
   }
   
   internal final override func mouseDragged (with event : NSEvent)
   {
      if mouseMode == 1
      {
         let point    = browser! .convert (event .locationInWindow, from: nil)
         let toVector = trackballProjectToSphere (from: point)
         
         rotation = Rotation4f (from: toVector, to: fromVector)
         
         if abs (rotation .angle) < SPIN_ANGLE && SFTime .now - downTime < MOTION_TIME
         {
            return
         }

         fromVector = toVector
         motionTime = SFTime .now

         do
         {
            activeViewpoint .orientationOffset = try getOrientationOffset (rotation, _throw: true)
            activeViewpoint .positionOffset    = getPositionOffset ()
         }
         catch
         {
            // Slide along critical angle.

            rotation = getHorizonRotation (rotation)

            activeViewpoint .orientationOffset = try! getOrientationOffset (rotation, _throw: false)
            activeViewpoint .positionOffset    = getPositionOffset ()
         }
      }
      
      else if mouseMode == 2
      {
         let toPoint     = pointOnCenterPlane (from: browser! .convert (event .locationInWindow, from: nil))
         let translation = activeViewpoint .userOrientation * (fromPoint - toPoint)

         activeViewpoint .positionOffset         += translation
         activeViewpoint .centerOfRotationOffset += translation

         fromPoint = toPoint
      }
   }
   
   internal final override func mouseUp (with event : NSEvent)
   {
      isActive = false
      
      if mouseMode == 1
      {
         if abs (rotation .angle) > SPIN_ANGLE && SFTime .now - motionTime < SPIN_RELEASE_TIME
         {
            rotation = slerp (Rotation4f .identity, rotation, t: SPIN_FACTOR)

            if browser! .browserOptions .StraightenHorizon && !activeViewpoint .types .contains (.GeoViewpoint)
            {
               rotation = getHorizonRotation (rotation)
            }

            addSpinning ()
         }
      }
      
      mouseMode = 0
   }
   
   internal final override func scrollWheel (with event : NSEvent)
   {
      removeSpinning ()
      
      activeViewpoint .transitionStop ()

      let step        = distanceToCenter * SCROLL_FACTOR
      let translation = activeViewpoint .userOrientation * Vector3f (0, 0, length (step) * Float (-event .deltaY))
      
      activeViewpoint .positionOffset += translation
   }
   
   private final func addSpinning ()
   {
      browser! .addBrowserInterest (event: .Browser_Event, id: "spin", handler: { $0 .spin () }, requester: self)
      browser! .setNeedsDisplay ()
   }
   
   private final func removeSpinning ()
   {
      browser! .removeBrowserInterest (event: .Browser_Event, id: "spin", requester: self)
   }
   
   private final func spin ()
   {
      let t = Float (FRAME_RATE / browser! .currentFrameRate)
      let r = slerp (Rotation4f .identity, rotation, t: t)
      
      activeViewpoint .orientationOffset = try! getOrientationOffset (r, _throw: false)
      activeViewpoint .positionOffset    = getPositionOffset ()
   }

   // Calculate positionOffset and orientationOffset for activeViewpoint.
   
   private final var orientationOffset = Rotation4f .identity
   
   private final func getPositionOffset () -> Vector3f
   {
      (activeViewpoint .orientationOffset * ~orientationOffset) * distanceToCenter - distanceToCenter + activeViewpoint .positionOffset
   }

   private final func getOrientationOffset (_ rotation : Rotation4f, _throw : Bool) throws -> Rotation4f
   {
      // Assign last value to global orientationOffset
      orientationOffset = activeViewpoint .orientationOffset

      var orientationOffsetAfter = activeViewpoint .userOrientation * rotation * ~activeViewpoint .getOrientation ()

      if browser! .browserOptions .StraightenHorizon && !activeViewpoint .types .contains (.GeoViewpoint)
      {
         orientationOffsetAfter = activeViewpoint .straightenHorizon (orientationOffsetAfter * activeViewpoint .getOrientation ()) * orientationOffsetAfter

         if !_throw
         {
            return orientationOffsetAfter
         }

         let userOrientation = orientationOffsetAfter * activeViewpoint .getOrientation ()
         let userVector      = userOrientation * Vector3f .zAxis

         if abs (dot (activeViewpoint .upVector, userVector)) < MAX_ANGLE
         {
            return orientationOffsetAfter
         }

         throw X3DError .NOT_SUPPORTED ("Not supported.")
      }

      return orientationOffsetAfter
   }
   
   /// Constrain `rotation` to a rotation paralled to horizon.
   private final func getHorizonRotation (_ rotation : Rotation4f) -> Rotation4f
   {
      let V = normalize (Vector3f .zAxis * rotation)
      let N = normalize (cross (activeViewpoint .upVector, V))
      let H = normalize (cross (N, activeViewpoint .upVector))

      return Rotation4f (from: H, to: Vector3f .zAxis)
   }
}
