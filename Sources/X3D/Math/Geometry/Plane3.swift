//
//  File.swift
//  
//
//  Created by Holger Seelig on 11.11.20.
//

public struct Plane3f
{
   // Member types
   
   public typealias Scalar  = Float
   public typealias Vector3 = Vector3f
   public typealias Line3   = Line3f

   // Members
   
   public private(set) var normal             : Vector3
   public private(set) var distanceFromOrigin : Scalar
   
   // Construction
   
   public init (point : Vector3, normal : Vector3)
   {
      self .normal             = normal
      self .distanceFromOrigin = dot (normal, point)
   }
   
   // Operations
   
   /// Returns the distance from point.
   public func distance (to point : Vector3) -> Scalar
   {
      return dot (point, normal) - distanceFromOrigin
   }

   /// Returns the perpendicular vector from point to this plane.
   public func perpendicularVector (from point : Vector3) -> Vector3
   {
      return normal * -distance (to: point)
   }

   ///  Returns the closest point on the plane to a given point @a point.
   public func closestPoint (to point : Vector3) -> Vector3
   {
      return point + perpendicularVector (from: point)
   }

   /// Returns the intersection with line point or nil denoting whether
   /// the intersection was successful.
   public func intersects (with line : Line3) -> Vector3?
   {
      // Check if the line is parallel to the plane.
      let theta = dot (line .direction, normal)

      // Plane and line are parallel.
      if theta == 0
      {
         return nil
      }

      // Plane and line are not parallel. The intersection point can be calculated now.
      let t     = (distanceFromOrigin - dot (normal, line .point)) / theta
      let point = line .point + line .direction * t

      return point
   }
}
