//
//  PlaneSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PlaneSensor :
   X3DDragSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "PlaneSensor" }
   internal final override class var component      : String { "PointingDeviceSensor" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFRotation public final var axisRotation        : Rotation4f = .identity
   @SFVec3f    public final var offset              : Vector3f = .zero
   @SFVec2f    public final var minPosition         : Vector2f = .zero
   @SFVec2f    public final var maxPosition         : Vector2f = -.one
   @SFVec3f    public final var translation_changed : Vector3f = .zero

   // Properties
   
   private final var planeSensor : Bool = false
   private final var line        : Line3f = Line3f (point: .zero, direction: .zero)
   private final var plane       : Plane3f = Plane3f (point: .zero, normal: .zero)
   private final var startPoint  : Vector3f = .zero
   private final var startOffset : Vector3f = .zero

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PlaneSensor)

      addField (.inputOutput, "metadata",            $metadata)
      addField (.inputOutput, "enabled",             $enabled)
      addField (.inputOutput, "description",         $description)
      addField (.inputOutput, "axisRotation",        $axisRotation)
      addField (.inputOutput, "autoOffset",          $autoOffset)
      addField (.inputOutput, "offset",              $offset)
      addField (.inputOutput, "minPosition",         $minPosition)
      addField (.inputOutput, "maxPosition",         $maxPosition)
      addField (.outputOnly,  "trackPoint_changed",  $trackPoint_changed)
      addField (.outputOnly,  "translation_changed", $translation_changed)
      addField (.outputOnly,  "isOver",              $isOver)
      addField (.outputOnly,  "isActive",            $isActive)

      $offset              .unit = .length
      $minPosition         .unit = .length
      $maxPosition         .unit = .length
      $translation_changed .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PlaneSensor
   {
      return PlaneSensor (with: executionContext)
   }
   
   // Event handlers
   
   internal final override func set_active (active : Bool,
                                            hit : Hit,
                                            modelViewMatrix : Matrix4f,
                                            projectionMatrix : Matrix4f,
                                            viewport : Vector4i)
   {
      super .set_active (active: active,
                         hit: hit,
                         modelViewMatrix: modelViewMatrix,
                         projectionMatrix: projectionMatrix,
                         viewport: viewport)
      
      if isActive
      {
         let invModelViewMatrix = modelViewMatrix .inverse
         let hitRay             = invModelViewMatrix * hit .hitRay
         let hitPoint           = invModelViewMatrix * hit .intersection .point

         if minPosition .x == maxPosition .x
         {
            let direction = axisRotation * Vector3f (0, abs (maxPosition .y - minPosition .y), 0)

            planeSensor = false
            line        = Line3f (point: hitPoint, direction: normalize (direction))
         }
         else if minPosition .y == maxPosition .y
         {
            let direction = axisRotation * Vector3f (abs (maxPosition .x - minPosition .x), 0, 0)

            planeSensor = false
            line        = Line3f (point: hitPoint, direction: normalize (direction))
         }
         else
         {
            planeSensor = true
            plane       = Plane3f (point: hitPoint, normal: axisRotation * Vector3f .zAxis)
         }

         if planeSensor
         {
            if let intersection = plane .intersects (with: hitRay)
            {
               startPoint = intersection

               trackStart (startPoint)
            }
         }
         else
         {
            if let intersection = lineTrackPoint (hit: hit,
                                                  line: line,
                                                  modelViewMatrix: modelViewMatrix,
                                                  projectionMatrix: projectionMatrix,
                                                  viewport: viewport)
            {
               startPoint = intersection
               
               if let intersection = lineTrackPoint (hit: hit,
                                                     line: Line3f (point: line .direction, direction: line .direction),
                                                     modelViewMatrix: modelViewMatrix,
                                                     projectionMatrix: projectionMatrix,
                                                     viewport: viewport)
               {
                  trackStart (intersection)
               }
               else
               {
                  trackStart (startPoint)
               }
            }
         }
      }
      else
      {
         if autoOffset
         {
            offset = translation_changed
         }
      }
   }
   
   internal final override func set_motion (hit : Hit,
                                            modelViewMatrix : Matrix4f,
                                            projectionMatrix : Matrix4f,
                                            viewport : Vector4i)
   {
      super .set_motion (hit: hit,
                         modelViewMatrix: modelViewMatrix,
                         projectionMatrix: projectionMatrix,
                         viewport: viewport)
      
      if planeSensor
      {
         let invModelViewMatrix = modelViewMatrix .inverse
         let hitRay             = invModelViewMatrix * hit .hitRay
         
         if let intersection = plane .intersects (with: hitRay)
         {
            track (intersection, intersection)
         }
      }
      else
      {
         if let intersection = lineTrackPoint (hit: hit,
                                               line: line,
                                               modelViewMatrix: modelViewMatrix,
                                               projectionMatrix: projectionMatrix,
                                               viewport: viewport)
         {
            let trackPoint = lineTrackPoint (hit: hit,
                                             line: Line3f (point: .zero, direction: line .direction),
                                             modelViewMatrix: modelViewMatrix,
                                             projectionMatrix: projectionMatrix,
                                             viewport: viewport)

            track (intersection, trackPoint!)
         }
      }
   }
   
   private final func trackStart (_ trackPoint : Vector3f)
   {
      startOffset         = offset
      trackPoint_changed  = trackPoint
      translation_changed = offset
   }
   
   private final func lineTrackPoint (hit : Hit,
                                      line : Line3f,
                                      modelViewMatrix : Matrix4f,
                                      projectionMatrix : Matrix4f,
                                      viewport : Vector4i) -> Vector3f?
   {
      let screenLine     = ViewVolume .projectLine (line, modelViewMatrix, projectionMatrix, viewport)
      let trackPoint1    = screenLine .closestPoint (to: Vector3f (hit .pointer, 0))
      let trackPointLine = ViewVolume .unProjectRay (trackPoint1 .x, trackPoint1 .y, modelViewMatrix, projectionMatrix, viewport)
      let intersection   = line .closestPoint (to: trackPointLine)

      return intersection
   }

   private final func track (_ endPoint : Vector3f, _ trackPoint : Vector3f)
   {
      var translation = ~axisRotation * (startOffset + endPoint - startPoint)

      // X component

      if minPosition .x <= maxPosition .x
      {
         translation .x = clamp (translation .x, min: minPosition .x, max: maxPosition .x)
      }

      // Y component

      if minPosition .y <= maxPosition .y
      {
         translation .y = clamp (translation .y, min: minPosition .y, max: maxPosition .y)
      }

      translation = axisRotation * translation

      if trackPoint != trackPoint_changed
      {
         trackPoint_changed = trackPoint
      }

      if translation != translation_changed
      {
         translation_changed = translation
      }
   }
}
