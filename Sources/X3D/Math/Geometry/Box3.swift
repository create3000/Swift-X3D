//
//  BBox.swift
//  X3D
//
//  Created by Holger Seelig on 05.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public struct Box3f
{
   // Member types
   
   public typealias Scalar  = Float
   public typealias Vector3 = Vector3f
   public typealias Vector4 = Vector4f
   public typealias Matrix4 = Matrix4f
   public typealias Line3   = Line3f

   // Properties
   
   public private(set) var matrix : Matrix4
   
   // Static properties
   
   public static let empty = Self ()
   
   /// Constructs an empty box.
   public init ()
   {
      matrix = Matrix4 (columns: (Vector4 (0, 0, 0, 0),
                                  Vector4 (0, 0, 0, 0),
                                  Vector4 (0, 0, 0, 0),
                                  Vector4 (0, 0, 0, 0)))
   }
   
   /// Constructs a box of `size` and `center`.
   public init (size : Vector3, center : Vector3)
   {
      matrix = Matrix4 (columns: (Vector4 (size .x / 2, 0, 0, 0),
                                  Vector4 (0, size .y / 2, 0, 0),
                                  Vector4 (0, 0, size .z / 2, 0),
                                  Vector4 (center .x, center .y, center .z, 1)))
   }
   
   /// Constructs a box of `min` and `max` extents.
   public init (min : Vector3, max : Vector3)
   {
      self .init (size: max - min, center: (max + min) / 2)
   }

   /// Constructs a box from `matrix`.
   public init (from matrix : Matrix4)
   {
      self .matrix = matrix
   }
   
   // Properties
   
   public var isEmpty : Bool { matrix [3] [3] == 0 }
   
   public var size : Vector3
   {
      let extents = absoluteExtents
   
      return extents .max - extents .min
   }

   public var center : Vector3 { Vector3 (matrix [3] [0], matrix [3] [1], matrix [3] [2]) }
   
   public var extents : (min: Vector3, max: Vector3)
   {
      let extents = absoluteExtents
      
      return (extents .min + center, extents .max + center)
   }
   
   private var absoluteExtents : (min: Vector3, max: Vector3)
   {
      let x = matrix .xAxis
      let y = matrix .yAxis
      let z = matrix .zAxis
      
      let r1 = y + z
      let r2 = z - y
      
      let p1 =  x + r1
      let p2 = r1 - x
      let p3 = r2 - x
      let p4 =  x + r2
      
      let p5 = -p3
      let p6 = -p4
      let p7 = -p1
      let p8 = -p2
      
      var min = Vector3 ( Scalar .infinity,  Scalar .infinity,  Scalar .infinity)
      var max = Vector3 (-Scalar .infinity, -Scalar .infinity, -Scalar .infinity)
      
      for p in [p1, p2, p3, p4, p5, p6, p7, p8]
      {
         min = simd_min (min, p)
         max = simd_max (max, p)
      }

      return (min, max)
   }
   
   public var points : [Vector3]
   {
      /*
       * p6 ---------- p5
       * | \           | \
       * | p2------------ p1
       * |  |          |  |
       * |  |          |  |
       * p7 |_________ p8 |
       *  \ |           \ |
       *   \|            \|
       *    p3 ---------- p4
       */

      var points = [Vector3] ()

      let x = matrix .xAxis
      let y = matrix .yAxis
      let z = matrix .zAxis

      let r1 = y + z
      let r2 = z - y

      points .append (x + r1)
      points .append (r1 - x)
      points .append (r2 - x)
      points .append (x + r2)

      points .append (-points [2])
      points .append (-points [3])
      points .append (-points [0])
      points .append (-points [1])

      for i in 0 ..< 8
      {
         points [i] += center
      }

      return points
   }

   public var normals : [Vector3]
   {
      var normals = [Vector3] ()

      let n = normalize (matrix)
      let x = n .xAxis
      let y = n .yAxis
      let z = n .zAxis

      normals .append (normalize (cross (y, z)))
      normals .append (normalize (cross (z, x)))
      normals .append (normalize (cross (x, y)))

      return normals
   }
   
   public var axes : [Vector3]
   {
      [
         matrix .xAxis,
         matrix .yAxis,
         matrix .zAxis,
      ]
   }

   // Operations
   
   public static func += (lhs : inout Self, rhs : Self)
   {
      lhs = lhs + rhs
   }
   
   public static func + (lhs : Self, rhs : Self) -> Self
   {
      if lhs .isEmpty
      {
         return rhs
      }
      
      if rhs .isEmpty
      {
         return lhs
      }
      
      let extents1 = rhs .extents
      let extents2 = lhs .extents
      let min1     = extents1 .min
      let max1     = extents1 .max
      let min2     = extents2 .min
      let max2     = extents2 .max
      
      return Self (min: simd_min (min1, min2), max: simd_max (max1, max2))
   }
   
   public static func *= (_ box : inout Self, _ matrix : Matrix4)
   {
      box .matrix *= matrix
   }
   
   public static func * (_ box : Self, _ matrix : Matrix4) -> Self
   {
      return Self (from: box .matrix * matrix)
   }
   
   public static func * (_ matrix : Matrix4, _ box : Self) -> Self
   {
      return Self (from: matrix * box .matrix)
   }
   
   public func contains (point : Vector3) -> Bool
   {
      let extents = self .extents
      let min     = extents .min
      let max     = extents .max

      return min .x <= point .x &&
             max .x >= point .x &&
             min .y <= point .y &&
             max .y >= point .y &&
             min .z <= point .z &&
             max .z >= point .z
   }

   
   private static let normals = [
      Vector3 (0,  0,  1), // front
      Vector3 (0,  0, -1), // back
      Vector3 (0,  1,  0), // top
      Vector3 (0, -1,  0), // bottom
      Vector3 (1,  0,  0)  // right
      // left: We do not have to test for left.
   ]
   
   public func intersects (with line : Line3) -> Bool
   {
      let extents = self .extents
      let min     = extents .min
      let max     = extents .max

      for i in 0 ..< 5
      {
         let plane = Plane3f (point: i .isOdd ? min : max, normal: Self .normals [i])
         
         guard let intersection = plane .intersects (with: line) else { continue }

         switch i
         {
            case 0, 1: do
            {
               if intersection .x >= min .x && intersection .x <= max .x &&
                  intersection .y >= min .y && intersection .y <= max .y
               {
                  return true
               }
            }
            case 2, 3: do
            {
               if intersection .x >= min .x && intersection .x <= max .x &&
                  intersection .z >= min .z && intersection .z <= max .z
               {
                  return true
               }
            }
            case 4: do
            {
               if intersection .y >= min .y && intersection .y <= max .y &&
                  intersection .z >= min .z && intersection .z <= max .z
               {
                  return true
               }
            }
            default:
               break
         }
      }
      
      return false
   }
}

extension Box3f :
   CustomStringConvertible,
   CustomDebugStringConvertible
{
   public var description      : String { "Box3f(size: \(size), center: \(center))" }
   public var debugDescription : String { description }
}

fileprivate func normalize (_ matrix : Matrix4f) -> Matrix4f
{
   var x = matrix .xAxis
   var y = matrix .yAxis
   var z = matrix .zAxis

   if norm (x) == 0 && norm (y) == 0 && norm (z) == 0
   {
      x = .xAxis
      y = .yAxis
      z = .zAxis
   }
   else
   {
      let axes : [Vector3f] = [.xAxis, .yAxis, .zAxis]

      if norm (x) == 0
      {
         x = cross (y, z)
   
         if norm (x) == 0
         {
            for a in axes
            {
               x = cross (a, y)
   
               if norm (x) == 0
               {
                  continue
               }
   
               break
            }
         }
   
         if norm (x) == 0
         {
            for a in axes
            {
               x = cross (a, z)
   
               if norm (x) == 0
               {
                  continue
               }
   
               break
            }
         }
   
         if norm (x) == 0
         {
            x = .xAxis
         }
         else
         {
            x = normalize (x)
         }
      }
   
      if (norm (y) == 0)
      {
         y = cross (z, x);
   
         if (norm (y) == 0)
         {
            for  a in axes
            {
               y = cross (a, z)
   
               if norm (y) == 0
               {
                  continue
               }
   
               break
            }
         }
   
         if norm (y) == 0
         {
            for a in axes
            {
               y = cross (a, x)
   
               if norm (y) == 0
               {
                  continue
               }
   
               break
            }
         }
   
         if norm (y) == 0
         {
            y = .yAxis
         }
         else
         {
            y = normalize (y)
         }
      }
   
      if norm (z) == 0
      {
         z = cross (x, y)
   
         if norm (z) == 0
         {
            for a in axes
            {
               z = cross (a, x)
   
               if norm (z) == 0
               {
                  continue
               }
   
               break
            }
         }
   
         if norm (z) == 0
         {
            for a in axes
            {
               z = cross (a, y)
   
               if norm (z) == 0
               {
                  continue
               }
   
               break
            }
         }
   
         if norm (z) == 0
         {
            z = .zAxis
         }
         else
         {
            z = normalize (z)
         }
      }
   }

   let o = matrix .origin

   return Matrix4f (columns: (Vector4f (x, 0),
                              Vector4f (y, 0),
                              Vector4f (z, 0),
                              Vector4f (o, 1)))
}
