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
