//
//  File.swift
//  
//
//  Created by Holger Seelig on 13.11.20.
//

public struct Cylinder3f
{
   // Member types
   
   public typealias Scalar    = Float
   public typealias Vector3   = Vector3f
   public typealias Rotation4 = Rotation4f
   public typealias Matrix4   = Matrix4f
   public typealias Line3     = Line3f

   // Members
   
   public private(set) var axis   : Line3
   public private(set) var radius : Scalar
   
   // Construction
   
   public init (axis : Line3, radius : Scalar)
   {
      self .axis   = axis
      self .radius = radius
   }
   
   // Operations
   
   public func intersects (with line : Line3) -> (enter : Vector3, exit : Vector3)?
   {
      // The intersection will actually be done on a radius 1 cylinder
      // aligned with the y axis, so we transform the line into that
      // space, then intersect, then transform the results back.
   
      // rotation to y axis
      let rotToYAxis = Rotation4 (from: axis .direction, to: .yAxis)
   
      // scale to unit space
      let scaleFactor = 1 / radius

      var toUnitCylSpace = Matrix4 .identity
      toUnitCylSpace = toUnitCylSpace .scale (Vector3 (scaleFactor, scaleFactor, scaleFactor))
      toUnitCylSpace = toUnitCylSpace .rotate (rotToYAxis)
   
      // find the given line un-translated
      let point             = line .point - axis .point
      let noTranslationLine = Line3 (point: point, direction: line .direction)

      // find the un-translated line in unit cylinder's space
      let cylLine = noTranslationLine * toUnitCylSpace
   
      // find the intersection on the unit cylinder
      guard let intersection = unitCylinderIntersects (with: cylLine) else { return nil }

      // transform back to original space
      let fromUnitCylSpace = inverse (toUnitCylSpace)

      var enter = fromUnitCylSpace * intersection .enter
      var exit  = fromUnitCylSpace * intersection .exit

      enter += axis .point
      exit  += axis .point
   
      return (enter, exit)
   }
   
   private func unitCylinderIntersects (with line : Line3) -> (enter : Vector3, exit : Vector3)?
   {
      var t0 : Scalar = 0
      var t1 : Scalar = 0

      let pos = line .point
      let dir = line .direction

      let A = dir [0] * dir [0] + dir [2] * dir [2]
      let B = 2 * (pos [0] * dir [0] + pos [2] * dir [2])
      let C = pos [0] * pos [0] + pos [2] * pos [2] - 1

      // discriminant = B^2 - 4AC
      let discr = B * B - 4 * A * C

      // if discriminant is negative, no intersection
      if discr < 0 { return nil }

      let sqroot = sqrt (discr)

      // magic to stabilize the answer
      if B > 0
      {
         t0 = -(2 * C) / (sqroot + B)
         t1 = -(sqroot + B) / (2 * A)
      }
      else
      {
         t0 = (2 * C) / (sqroot - B)
         t1 = (sqroot - B) / (2 * A)
      }

      let enter = simd_muladd (dir, Vector3 (repeating: t0), pos)
      let exit  = simd_muladd (dir, Vector3 (repeating: t1), pos)

      return (enter, exit)
   }
}
