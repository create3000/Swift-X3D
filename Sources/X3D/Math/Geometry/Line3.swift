//
//  File.swift
//  
//
//  Created by Holger Seelig on 11.11.20.
//

public struct Line3f
{
   public typealias Scalar  = Float
   public typealias Vector3 = Vector3f
   public typealias Matrix4 = Matrix4f
   
   public private(set) var point     : Vector3
   public private(set) var direction : Vector3
   
   public init (point : Vector3f, direction : Vector3)
   {
      self .point     = point
      self .direction = direction
   }
   
   public init (point1 : Vector3, point2 : Vector3)
   {
      self .init (point: point1, direction: normalize (point2 - point1))
   }
   
   public static func *= (_ line : inout Self, _ matrix : Matrix4)
   {
      line .point     = line .point * matrix
      line .direction = normalize (line .direction * matrix .submatrix)
   }
   
   public static func * (_ line : Self, _ matrix : Matrix4) -> Self
   {
      let point     = line .point * matrix
      let direction = normalize (line .direction * matrix .submatrix)

      return Self (point: point, direction: direction)
   }
   
   public static func * (_ matrix : Matrix4, _ line : Self) -> Self
   {
      let point     = matrix * line .point
      let direction = normalize (matrix .submatrix * line .direction)

      return Self (point: point, direction: direction)
   }
   
   public func intersects (_ A : Vector3, _ B : Vector3, _ C : Vector3) -> (u : Scalar, v : Scalar, t : Scalar)?
   {
      // Find vectors for two edges sharing vert0.
      let edge1 = B - A
      let edge2 = C - A

      // Begin calculating determinant - also used to calculate U parameter.
      let pvec = cross (direction, edge2)

      // If determinant is near zero, ray lies in plane of triangle.
      let det = dot (edge1, pvec)

      // Non culling intersection.

      if det == 0
      {
         return nil
      }

      let inv_det = 1 / det

      // Calculate distance from vert0 to ray point.
      let tvec = point - A

      // Calculate U parameter and test bounds.
      let u = dot (tvec, pvec) * inv_det

      if u < 0 || u > 1
      {
         return nil
      }

      // Prepare to test V parameter.
      let qvec = cross (tvec, edge1)

      // Calculate V parameter and test bounds.
      let v = dot (direction, qvec) * inv_det

      if v < 0 || u + v > 1
      {
         return nil
      }

      //let t = dot (edge2, qvec) * inv_det

      return (1 - u - v, u, v)
   }
}

extension Line3f :
   CustomStringConvertible,
   CustomDebugStringConvertible
{
   public var description      : String { "Line3f(point: \(point), direction: \(direction))" }
   public var debugDescription : String { description }
}
