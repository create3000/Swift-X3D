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
   
   // Properties
   
   public private(set) var matrix : Matrix4
   
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
}

extension Box3f :
   CustomStringConvertible,
   CustomDebugStringConvertible
{
   public var description      : String { "Box3f(size: \(size), center: \(center))" }
   public var debugDescription : String { description }
}
