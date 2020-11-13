//
//  SphereSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class SphereSensor :
   X3DDragSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "SphereSensor" }
   internal final override class var component      : String { "PointingDeviceSensor" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFRotation public final var offset           : Rotation4f = Rotation4f (0, 1, 0, 0)
   @SFRotation public final var rotation_changed : Rotation4f = .identity

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.SphereSensor)

      addField (.inputOutput, "metadata",           $metadata)
      addField (.inputOutput, "enabled",            $enabled)
      addField (.inputOutput, "description",        $description)
      addField (.inputOutput, "autoOffset",         $autoOffset)
      addField (.inputOutput, "offset",             $offset)
      addField (.outputOnly,  "trackPoint_changed", $trackPoint_changed)
      addField (.outputOnly,  "rotation_changed",   $rotation_changed)
      addField (.outputOnly,  "isOver",             $isOver)
      addField (.outputOnly,  "isActive",           $isActive)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SphereSensor
   {
      return SphereSensor (with: executionContext)
   }
   
   // Event handlers
   
   private final var sphere      : Sphere3f = Sphere3f (center: .zero, radius: 0)
   private final var zPlane      : Plane3f = Plane3f (point: .zero, normal: .zero)
   private final var behind      : Bool = false
   private final var fromVector  : Vector3f = .zero
   private final var startPoint  : Vector3f = .zero
   private final var startOffset : Rotation4f = .identity

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
         let hitPoint           = invModelViewMatrix * hit .intersection .point
         let center             = Vector3f .zero

         sphere = Sphere3f (center: center, radius: length (hitPoint))
         zPlane = Plane3f (point: center, normal: normalize (invModelViewMatrix .submatrix * Vector3f .zAxis)) // Screen aligned Z-plane
         behind = zPlane .distance (to: hitPoint) < 0

         fromVector  = hitPoint
         startPoint  = hitPoint
         startOffset = offset

         trackPoint_changed = hitPoint
         rotation_changed   = offset
      }
      else
      {
         if autoOffset
         {
            offset = rotation_changed
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
      
      let invModelViewMatrix = modelViewMatrix .inverse
      var hitRay             = invModelViewMatrix * hit .hitRay
      
      var trackPoint = Vector3f .zero

      if let intersection = getTrackPoint (hitRay, behind: behind)
      {
         let zAxis = normalize (invModelViewMatrix .submatrix * Vector3f .zAxis) // Camera direction

         trackPoint = intersection
         zPlane     = Plane3f (point: trackPoint, normal: zAxis) // Screen aligned Z-plane
      }
      else
      {
         // Find trackPoint on the plane with sphere

         let tangentPoint = zPlane .intersects (with: hitRay)!

         hitRay     = Line3f (point: tangentPoint, direction: normalize (sphere .center - tangentPoint))
         trackPoint = getTrackPoint (hitRay, behind: false)!

         // Find trackPoint behind sphere

         let triNormal     = normal (sphere .center, trackPoint, startPoint)
         let dirFromCenter = normalize (trackPoint - sphere .center)
         let normal        = normalize (cross (triNormal, dirFromCenter))
         let point1        = trackPoint - normal * length (tangentPoint - trackPoint)

         hitRay     = Line3f (point1: point1, point2: sphere .center)
         trackPoint = getTrackPoint (hitRay, behind: false)!
      }

      let toVector = trackPoint - sphere .center
      var rotation = Rotation4f (from: fromVector, to: toVector)

      if behind
      {
         rotation = rotation .inverse
      }
      
      trackPoint_changed = trackPoint
      rotation_changed   = rotation * startOffset
   }
   
   private final func getTrackPoint (_ hitRay : Line3f, behind : Bool) -> Vector3f?
   {
      if let (enter, exit) = sphere .intersects (with: hitRay)
      {
         if (length (hitRay .point - exit) < length (hitRay .point - enter)) == behind
         {
            return enter
         }
         else
         {
            return exit
         }
      }
      else
      {
         return nil
      }
   }
}
