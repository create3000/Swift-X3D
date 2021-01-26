//
//  CylinderSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CylinderSensor :
   X3DDragSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "CylinderSensor" }
   internal final override class var component      : String { "PointingDeviceSensor" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFRotation public final var axisRotation     : Rotation4f = Rotation4f (0, 1, 0, 0)
   @SFFloat    public final var diskAngle        : Float = 0.261792
   @SFFloat    public final var minAngle         : Float = 0
   @SFFloat    public final var maxAngle         : Float = -1
   @SFFloat    public final var offset           : Float = 0
   @SFRotation public final var rotation_changed : Rotation4f = .identity

   // Properties
   
   private final var cylinder    : Cylinder3f = Cylinder3f (axis: Line3f (point: .zero, direction: .zero), radius: 0)
   private final var disk        : Bool = false
   private final var behind      : Bool = false
   private final var yPlane      : Plane3f = Plane3f (point: .zero, normal: .zero)
   private final var zPlane      : Plane3f = Plane3f (point: .zero, normal: .zero)
   private final var sxPlane     : Plane3f = Plane3f (point: .zero, normal: .zero)
   private final var szNormal    : Vector3f = .zero
   private final var startVector : Vector3f = .zero
   private final var fromVector  : Vector3f = .zero
   private final var startOffset : Rotation4f = .identity
   private final var angle       : Float = 0
   
   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.CylinderSensor)

      addField (.inputOutput, "metadata",           $metadata)
      addField (.inputOutput, "enabled",            $enabled)
      addField (.inputOutput, "description",        $description)
      addField (.inputOutput, "axisRotation",       $axisRotation)
      addField (.inputOutput, "diskAngle",          $diskAngle)
      addField (.inputOutput, "minAngle",           $minAngle)
      addField (.inputOutput, "maxAngle",           $maxAngle)
      addField (.inputOutput, "offset",             $offset)
      addField (.inputOutput, "autoOffset",         $autoOffset)
      addField (.outputOnly,  "trackPoint_changed", $trackPoint_changed)
      addField (.outputOnly,  "rotation_changed",   $rotation_changed)
      addField (.outputOnly,  "isOver",             $isOver)
      addField (.outputOnly,  "isActive",           $isActive)

      $diskAngle .unit = .angle
      $minAngle  .unit = .angle
      $maxAngle  .unit = .angle
      $offset    .unit = .angle
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CylinderSensor
   {
      return CylinderSensor (with: executionContext)
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

         let yAxis      = axisRotation * Vector3f .yAxis
         let cameraBack = normalize (invModelViewMatrix .submatrix * Vector3f .zAxis)

         let axis   = Line3f (point: .zero, direction: yAxis)
         let radius = length (axis .perpendicularVector (from: hitPoint))

         cylinder = Cylinder3f (axis: axis, radius: radius)

         disk   = abs (dot (cameraBack, yAxis)) > cos (diskAngle)
         behind = isBehind (hitRay, hitPoint)

         yPlane = Plane3f (point: hitPoint, normal: yAxis)      // Sensor aligned y-plane
         zPlane = Plane3f (point: hitPoint, normal: cameraBack) // Screen aligned z-plane

         // Compute normal as in Billboard with yAxis as axis of rotation.
         let billboardToViewer = invModelViewMatrix .origin
         let sxNormal          = normalize (cross (yAxis, billboardToViewer))

         sxPlane  = Plane3f (point: .zero, normal: sxNormal) // Billboarded special x-plane made parallel to sensors axis.
         szNormal = normalize (cross (sxNormal, yAxis))      // Billboarded special z-normal made parallel to sensors axis.

         var trackPoint = Vector3f .zero

         if disk
         {
            trackPoint = yPlane .intersects (with: hitRay)!
         }
         else
         {
            trackPoint = getTrackPoint (hitRay)
         }

         fromVector  = -cylinder .axis .perpendicularVector (from: trackPoint)
         startOffset = Rotation4f (axis: yAxis, angle: offset)

         trackPoint_changed = trackPoint
         rotation_changed   = startOffset

         // For min/max angle.

         angle       = offset
         startVector = rotation_changed * axisRotation * Vector3f .zAxis
      }
      else
      {
         if autoOffset
         {
            offset = getAngle (rotation_changed)
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
      let hitRay             = invModelViewMatrix * hit .hitRay
      
      // Make trackPoint.
      
      var trackPoint = Vector3f .zero

      if disk
      {
         trackPoint = yPlane .intersects (with: hitRay)!
      }
      else
      {
         trackPoint = getTrackPoint (hitRay)
      }

      trackPoint_changed = trackPoint
      
      // Make rotation.

      let toVector = -cylinder .axis .perpendicularVector (from: trackPoint)
      var rotation = Rotation4f (from: fromVector, to: toVector)

      if disk
      {
         // The trackpoint can swap behind the viewpoint if viewpoint is a Viewpoint node
         // as the viewing volume is not a cube where the picking ray goes straight up.
         // This phenomenon is very clear on the viewport corners.

         let trackPoint_ = modelViewMatrix * trackPoint

         if trackPoint_ .z > 0
         {
            rotation = Rotation4f (axis: yPlane .normal, angle: .pi) * rotation
         }
      }
      else
      {
         if behind
         {
            rotation = rotation .inverse
         }
      }

      rotation = rotation * startOffset

      if minAngle > maxAngle
      {
         rotation_changed = rotation
      }
      else
      {
         let endVector     = rotation * axisRotation * Vector3f .zAxis
         let deltaRotation = Rotation4f (from: startVector, to: endVector)
         let axis          = axisRotation * Vector3f .yAxis
         let sign          = dot (axis, deltaRotation .axis) > 0 ? 1 : -1
         let min           = minAngle
         let max           = maxAngle

         angle += Float (sign) * deltaRotation .angle

         startVector = endVector

         if angle < min
         {
            rotation = Rotation4f (axis: cylinder .axis .direction, angle: min)
         }
         else if angle > max
         {
            rotation = Rotation4f (axis: cylinder .axis .direction, angle: max)
         }
         else
         {
            rotation = Rotation4f (axis: cylinder .axis .direction, angle: angle)
         }

         if rotation_changed != rotation
         {
            rotation_changed = rotation
         }
      }
   }
   
   private final func isBehind (_ hitRay : Line3f, _ hitPoint : Vector3f) -> Bool
   {
      let (intersection1, intersection2) = cylinder .intersects (with: hitRay)!
      
      return length (hitPoint - intersection1) > length (hitPoint - intersection2)
   }

   private final func getTrackPoint (_ hitRay : Line3f) -> Vector3f
   {
      let zPoint    = zPlane .intersects (with: hitRay)!
      let axisPoint = zPoint + cylinder .axis .perpendicularVector (from: zPoint)
      let distance  = sxPlane .distance (to: zPoint) / cylinder .radius
      let section   = floor ((distance + 1) / 2)

      // Use asin on the cylinder and outside linear angle.
      let sinp       = interval (distance, low: -1, high: 1)
      let phi        = section == 0 ? asin (sinp) : sinp * .pi / 2
      let angle      = phi + section * .pi
      let rotation   = Rotation4f (axis: cylinder .axis .direction, angle: angle);
      let trackPoint = rotation * (szNormal * cylinder .radius) + axisPoint

      return trackPoint
   }

   // Returns an angle in the interval [-2pi,2pi]

   private final func getAngle (_ rotation : Rotation4f) -> Float
   {
      if dot (rotation .axis, cylinder .axis .direction) > 0
      {
         return rotation .angle
      }
      else
      {
         return -rotation .angle
      }
   }
}
