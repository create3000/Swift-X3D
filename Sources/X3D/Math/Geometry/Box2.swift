//
//  File.swift
//  
//
//  Created by Holger Seelig on 03.11.20.
//

public struct Box2f
{
   // Member types
   
   public typealias Scalar  = Float
   public typealias Vector2 = Vector2f
   public typealias Vector3 = Vector3f
   public typealias Matrix3 = Matrix3f
   
   // Prperties
   
   public private(set) var matrix : Matrix3
   
   /// Constructs an empty box.
   public init ()
   {
      matrix = Matrix3 (columns: (Vector3 (0, 0, 0),
                                  Vector3 (0, 0, 0),
                                  Vector3 (0, 0, 0)))
   }
   
   /// Constructs a box of `size` and `center`.
   public init (size : Vector2, center : Vector2)
   {
      matrix = Matrix3 (columns: (Vector3 (size .x / 2, 0, 0),
                                  Vector3 (0, size .y / 2, 0),
                                  Vector3 (center .x, center .y, 1)))
   }
   
   /// Constructs a box of `min` and `max` extents.
   public init (min : Vector2, max : Vector2)
   {
      self .init (size: max - min, center: (max + min) / 2)
   }

   /// Constructs a box from `matrix`.
   public init (from matrix : Matrix3)
   {
      self .matrix = matrix
   }

   // Properties
   
   public var isEmpty : Bool { matrix [2] [2] == 0 }
   
   public var size : Vector2
   {
      let extents = absoluteExtents
   
      return extents .max - extents .min
   }

   public var center : Vector2 { Vector2 (matrix [2] [0], matrix [2] [1]) }
   
   public var extents : (min: Vector2, max: Vector2)
   {
      let extents = absoluteExtents
      
      return (extents .min + center, extents .max + center)
   }
   
   private var absoluteExtents : (min: Vector2, max: Vector2)
   {
      let x = matrix .xAxis
      let y = matrix .yAxis
      
      let p1 = x + y
      let p2 = y - x
      let p3 = -p1
      let p4 = -p2

      var min = Vector2 ( Scalar .infinity,  Scalar .infinity)
      var max = Vector2 (-Scalar .infinity, -Scalar .infinity)
      
      for p in [p1, p2, p3, p4]
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
}

extension Box2f :
   CustomStringConvertible,
   CustomDebugStringConvertible
{
   public var description      : String { "Box2f(size: \(size), center: \(center))" }
   public var debugDescription : String { description }
}
