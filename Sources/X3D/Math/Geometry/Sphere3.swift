//
//  File.swift
//  
//
//  Created by Holger Seelig on 13.11.20.
//

public struct Sphere3f
{
   // Member types
   
   public typealias Scalar  = Float
   public typealias Vector3 = Vector3f
   public typealias Line3   = Line3f

   // Properties
   
   public private(set) var center : Vector3
   public private(set) var radius : Scalar
   
   // Construction
   
   public init (center : Vector3, radius : Scalar)
   {
      self .center = center
      self .radius = radius
   }
   
   // Operations
   
   /// Returns true if the point intersects with this sphere.
   public func intersects (with point : Vector3) -> Bool
   {
      return length (point - center) <= radius
   }

   ///  Returns true if the line intersects with this sphere.
   public func intersects (with line : Line3) -> (enter : Vector3, exit : Vector3)?
   {
      // https://github.com/Alexpux/Coin3D/blob/master/src/base/SbSphere.cpp
      let linepos = line .point
      let linedir = line .direction

      let scenter = center
      let r       = radius

      let b = 2 * (dot (linepos, linedir) - dot (scenter, linedir))
      let c = (linepos [0] * linepos [0] + linepos [1] * linepos [1] + linepos [2] * linepos [2]) +
              (scenter [0] * scenter [0] + scenter [1] * scenter [1] + scenter [2] * scenter [2]) -
                  2 * dot (linepos, scenter) - r * r

      let core = b * b - 4 * c

      if core >= 0
      {
         var t1 = (-b + sqrt (core)) / 2
         var t2 = (-b - sqrt (core)) / 2

         if t1 > t2
         {
            swap (&t1, &t2)
         }

         let enter = simd_muladd (Vector3 (repeating: t1), linedir, linepos)
         let exit  = simd_muladd (Vector3 (repeating: t2), linedir, linepos)
         
         return (enter, exit)
      }
      else
      {
         return nil
      }
   }

   /// Returns true if the triangle of points A, B and C intersects with this sphere.
   public func intersects (_ A : Vector3, _ B : Vector3, _ C : Vector3) -> Bool
   {
      let P = center
      let r = radius

      let A = A - P
      let B = B - P
      let C = C - P

      // Testing if sphere lies outside the triangle plane.
      let rr   = r * r
      let V    = cross (B - A, C - A)
      let d    = dot (A, V)
      let e    = dot (V, V)
      let sep1 = d * d > rr * e

      if sep1
      {
         return false
      }

      // Testing if sphere lies outside a triangle vertex.
      let aa   = dot (A, A)
      let ab   = dot (A, B)
      let ac   = dot (A, C)
      let bb   = dot (B, B)
      let bc   = dot (B, C)
      let cc   = dot (C, C)
      let sep2 = (aa > rr) && (ab > aa) && (ac > aa)
      let sep3 = (bb > rr) && (ab > bb) && (bc > bb)
      let sep4 = (cc > rr) && (ac > cc) && (bc > cc)

      if sep2 || sep3 || sep4
      {
         return false
      }

      // Testing if sphere lies outside a triangle edge.
      let AB   = B - A
      let BC   = C - B
      let CA   = A - C
      let d1   = ab - aa
      let d2   = bc - bb
      let d3   = ac - cc
      let e1   = dot (AB, AB)
      let e2   = dot (BC, BC)
      let e3   = dot (CA, CA)
      let Q1   = A * e1 - d1 * AB
      let Q2   = B * e2 - d2 * BC
      let Q3   = C * e3 - d3 * CA
      let QC   = C * e1 - Q1
      let QA   = A * e2 - Q2
      let QB   = B * e3 - Q3
      let sep5 = (dot (Q1, Q1) > rr * e1 * e1) && (dot (Q1, QC) > 0)
      let sep6 = (dot (Q2, Q2) > rr * e2 * e2) && (dot (Q2, QA) > 0)
      let sep7 = (dot (Q3, Q3) > rr * e3 * e3) && (dot (Q3, QB) > 0)

      if sep5 || sep6 || sep7
      {
         return false
      }

      return true
   }
}
