//
//  Rotations.swift
//  X3D
//
//  Created by Holger Seelig on 26.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import simd

public struct Rotation4d
{
   // Member types
   
   public typealias Scalar      = Double
   public typealias Quaternion4 = Quaternion4d
   public typealias Vector3     = Vector3d
   public typealias Matrix3     = Matrix3d
   public typealias Matrix4     = Matrix4d
   
   // Static properties
   
   public static let identity = Self ()
   
   // Properties
   
   public private(set) var quat : Quaternion4
   
   // Construction
   
   public init ()
   {
      self .quat  = .identity
      self .axis  = .zAxis
      self .angle = 0
   }
   
   public init (_ x : Scalar, _ y : Scalar, _ z : Scalar, _ angle : Scalar)
   {
      self .quat  = Quaternion4 (angle: angle, axis: Vector3 (x, y, z)) .normalized
      self .axis  = Vector3 (x, y, z)
      self .angle = angle
   }
   
   public init (axis : Vector3, angle : Scalar)
   {
      self .quat  = Quaternion4 (angle: angle, axis: axis) .normalized
      self .axis  = axis
      self .angle = angle
   }

   public init (from fromVector : Vector3, to toVector : Vector3)
   {
      // https://bitbucket.org/Coin3D/coin/src/abc9f50968c9/src/base/SbRotation.cpp
      
      let from = normalize (fromVector)
      let to   = normalize (toVector)

      let cos_angle = clamp (dot (from, to), min: -1, max: 1)
      var crossvec  = normalize (cross (from, to))
      let crosslen  = length (crossvec)

      if crosslen == 0
      {
         // Parallel vectors
         // Check if they are pointing in the same direction.
         if cos_angle > 0
         {
            // standard rotation
            self .quat = .identity
         }
         // Ok, so they are parallel and pointing in the opposite direction
         // of each other.
         else
         {
            // Try crossing with x axis.
            var t = cross (from, .xAxis)

            // If not ok, cross with y axis.
            if norm (t) == 0
            {
               t = cross (from, .yAxis)
            }

            t = normalize (t)

            self .quat = Quaternion4 (ix: t [0], iy: t [1], iz: t [2], r: 0);
         }
      }
      else
      {
         // Vectors are not parallel
         // The abs () wrapping is to avoid problems when `dot' "overflows" a tiny wee bit,
         // which can lead to sqrt () returning NaN.
         crossvec *= sqrt (abs (1 - cos_angle) / 2)
         
         self .quat = Quaternion4 (ix: crossvec [0],
                                   iy: crossvec [1],
                                   iz: crossvec [2],
                                   r: sqrt (abs (1 + cos_angle) / 2))
      }

      self .axis  = self .quat .axis
      self .angle = self .quat .angle
   }

   public init (_ rotationMatrix : Matrix3)
   {
      self .quat  = Quaternion4 (rotationMatrix) .normalized
      self .axis  = self .quat .axis
      self .angle = self .quat .angle
   }
   
   public init (_ rotationMatrix : Matrix4)
   {
      self .quat  = Quaternion4 (rotationMatrix) .normalized
      self .axis  = self .quat .axis
      self .angle = self .quat .angle
   }

   public init (_ quat : Quaternion4)
   {
      self .quat  = quat .normalized
      self .axis  = self .quat .axis
      self .angle = self .quat .angle
   }

   // Properties
   
   public var axis : Vector3
   {
      didSet { quat = Quaternion4 (angle: angle, axis: axis) }
   }
   
   public var angle : Scalar
   {
      didSet { quat = Quaternion4 (angle: angle, axis: axis) }
   }

   public var inverse : Self
   {
      return Self (quat .inverse)
   }
   
   // Actions
   
   public func act (_ vector : Vector3) -> Vector3
   {
      return quat .act (vector)
   }
   
   // Operations
   
   public static func == (_ lhs : Self, _ rhs : Self) -> Bool
   {
      return lhs .quat == rhs .quat
   }
   
   public static func != (_ lhs : Self, _ rhs : Self) -> Bool
   {
      return lhs .quat != rhs .quat
   }

   public static prefix func ~ (_ rotation : Self) -> Self
   {
      return rotation .inverse
   }

   public static func *= (lhs : inout Self, rhs : Self)
   {
      lhs .quat = simd_normalize (lhs .quat * rhs .quat)
   }

   public static func * (_ lhs : Self, _ rhs : Self) -> Self
   {
      return Self (lhs .quat * rhs .quat)
   }
   
   public static func * (_ vector: Vector3, rotation: Self) -> Vector3
   {
      return rotation .quat .inverse .act (vector)
   }
   
   public static func * (_ rotation: Self, vector: Vector3) -> Vector3
   {
      return rotation .quat .act (vector)
   }
}

public struct Rotation4f
{
   // Member types
   
   public typealias Scalar      = Float
   public typealias Quaternion4 = Quaternion4f
   public typealias Vector3     = Vector3f
   public typealias Matrix3     = Matrix3f
   public typealias Matrix4     = Matrix4f
   
   // Static properties
   
   public static let identity = Self ()
   
   // Properties
   
   public private(set) var quat : Quaternion4
   
   // Construction
   
   public init ()
   {
      self .quat  = .identity
      self .axis  = .zAxis
      self .angle = 0
   }
   
   public init (_ x : Scalar, _ y : Scalar, _ z : Scalar, _ angle : Scalar)
   {
      self .quat  = Quaternion4 (angle: angle, axis: Vector3 (x, y, z)) .normalized
      self .axis  = Vector3 (x, y, z)
      self .angle = angle
   }
   
   public init (axis : Vector3, angle : Scalar)
   {
      self .quat  = Quaternion4 (angle: angle, axis: axis) .normalized
      self .axis  = axis
      self .angle = angle
   }
   
   public init (from fromVector : Vector3, to toVector : Vector3)
   {
      // https://bitbucket.org/Coin3D/coin/src/abc9f50968c9/src/base/SbRotation.cpp
      
      let from = normalize (fromVector)
      let to   = normalize (toVector)

      let cos_angle = clamp (dot (from, to), min: -1, max: 1)
      var crossvec  = normalize (cross (from, to))
      let crosslen  = length (crossvec)

      if crosslen == 0
      {
         // Parallel vectors
         // Check if they are pointing in the same direction.
         if cos_angle > 0
         {
            // standard rotation
            self .quat = .identity
         }
         // Ok, so they are parallel and pointing in the opposite direction
         // of each other.
         else
         {
            // Try crossing with x axis.
            var t = cross (from, .xAxis)

            // If not ok, cross with y axis.
            if norm (t) == 0
            {
               t = cross (from, .yAxis)
            }

            t = normalize (t)

            self .quat = Quaternion4 (ix: t [0], iy: t [1], iz: t [2], r: 0);
         }
      }
      else
      {
         // Vectors are not parallel
         // The abs () wrapping is to avoid problems when `dot' "overflows" a tiny wee bit,
         // which can lead to sqrt () returning NaN.
         crossvec *= sqrt (abs (1 - cos_angle) / 2)
         
         self .quat = Quaternion4 (ix: crossvec [0],
                                   iy: crossvec [1],
                                   iz: crossvec [2],
                                   r: sqrt (abs (1 + cos_angle) / 2))
      }

      self .axis  = self .quat .axis
      self .angle = self .quat .angle
   }
   
   public init (_ rotationMatrix : Matrix3)
   {
      self .quat  = Quaternion4 (rotationMatrix) .normalized
      self .axis  = self .quat .axis
      self .angle = self .quat .angle
   }
   
   public init (_ rotationMatrix : Matrix4)
   {
      self .quat  = Quaternion4 (rotationMatrix) .normalized
      self .axis  = self .quat .axis
      self .angle = self .quat .angle
   }
   
   public init (_ quat : Quaternion4)
   {
      self .quat  = quat .normalized
      self .axis  = self .quat .axis
      self .angle = self .quat .angle
   }
   
   // Properties
   
   public var axis : Vector3
   {
      didSet { quat = Quaternion4 (angle: angle, axis: axis) }
   }
   
   public var angle : Scalar
   {
      didSet { quat = Quaternion4 (angle: angle, axis: axis) }
   }
   
   public var inverse : Self
   {
      return Self (quat .inverse)
   }
   
   // Actions
   
   public func act (_ vector : Vector3) -> Vector3
   {
      return quat .act (vector)
   }
   
   // Operations
   
   public static func == (_ lhs : Self, _ rhs : Self) -> Bool
   {
      return lhs .quat == rhs .quat
   }
   
   public static func != (_ lhs : Self, _ rhs : Self) -> Bool
   {
      return lhs .quat != rhs .quat
   }
   
   public static prefix func ~ (_ rotation : Self) -> Self
   {
      return rotation .inverse
   }
   
   public static func *= (lhs : inout Self, rhs : Self)
   {
      lhs .quat = simd_normalize (lhs .quat * rhs .quat)
   }
   
   public static func * (_ lhs : Self, _ rhs : Self) -> Self
   {
      return Self (lhs .quat * rhs .quat)
   }
   
   public static func * (_ vector: Vector3, rotation: Self) -> Vector3
   {
      return rotation .quat .inverse .act (vector)
   }
   
   public static func * (_ rotation: Self, vector: Vector3) -> Vector3
   {
      return rotation .quat .act (vector)
   }
}

extension Rotation4d :
   CustomStringConvertible,
   CustomDebugStringConvertible
{
   public var description : String { "Rotation4d(axis: \(axis), angle: \(angle))" }
   public var debugDescription : String { description }
}

extension Rotation4f :
   CustomStringConvertible,
   CustomDebugStringConvertible
{
   public var description : String { "Rotation4f(axis: \(axis), angle: \(angle))" }
   public var debugDescription : String { description }
}

// Operations

@inlinable
public func inverse (_ rotation : Rotation4d) -> Rotation4d
{
   return rotation .inverse
}

@inlinable
public func inverse (_ rotation : Rotation4f) -> Rotation4f
{
   return rotation .inverse
}

public func slerp (_ from : Rotation4d, _ to : Rotation4d, t : Double) -> Rotation4d
{
   return Rotation4d (simd_slerp (from .quat, to .quat, t))
}

public func slerp (_ from : Rotation4f, _ to : Rotation4f, t : Float) -> Rotation4f
{
   return Rotation4f (simd_slerp (from .quat, to .quat, t))
}
