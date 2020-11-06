//
//  Quaternion.swift
//  X3D
//
//  Created by Holger Seelig on 05.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import simd

public typealias Quaternion4d = simd_quatd
public typealias Quaternion4f = simd_quatf

// Extensions

extension Quaternion4d
{
   public static let identity = Quaternion4d (ix: 0, iy: 0, iz: 0, r: 1)
   
   public init (from fromVector : Vector3d, to toVector : Vector3d)
   {
      // https://bitbucket.org/Coin3D/coin/src/abc9f50968c9/src/base/SbRotation.cpp
      
      let from = normalize (fromVector)
      let to   = normalize (toVector)

      let cos_angle = clamp (dot (from, to), min: -1, max: 1)
      var crossvec  = normalize (cross (from, to))
      let crosslen  = simd .length (crossvec)

      if crosslen == 0
      {
         // Parallel vectors
         // Check if they are pointing in the same direction.
         if cos_angle > 0
         {
            // standard rotation
            self = .identity
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

            self = Self (ix: t [0], iy: t [1], iz: t [2], r: 0);
         }
      }
      else
      {
         // Vectors are not parallel
         // The abs () wrapping is to avoid problems when `dot' "overflows" a tiny wee bit,
         // which can lead to sqrt () returning NaN.
         crossvec *= sqrt (abs (1 - cos_angle) / 2)
         
         self = Self (ix: crossvec [0],
                      iy: crossvec [1],
                      iz: crossvec [2],
                      r: sqrt (abs (1 + cos_angle) / 2))
      }
   }
   
   public var axis : Vector3d
   {
      if abs (real) > 1
      {
         return Vector3d .zAxis
      }
      else
      {
         let angle = acos (real) * 2
         let scale = sin (angle / 2)

         if scale == 0
         {
            return Vector3d .zAxis
         }
         else
         {
            return imag / scale
         }
      }
   }
   
   public var normalized : Quaternion4d
   {
      let l = length
      
      if l != 0
      {
         return self / l
      }
      
      return Self ()
   }
}

extension Quaternion4f
{
   public static let identity = Quaternion4f (ix: 0, iy: 0, iz: 0, r: 1)
   
   public init (from fromVector : Vector3f, to toVector : Vector3f)
   {
      // https://bitbucket.org/Coin3D/coin/src/abc9f50968c9/src/base/SbRotation.cpp
      
      let from = normalize (fromVector)
      let to   = normalize (toVector)

      let cos_angle = clamp (dot (from, to), min: -1, max: 1)
      var crossvec  = normalize (cross (from, to))
      let crosslen  = simd .length (crossvec)

      if crosslen == 0
      {
         // Parallel vectors
         // Check if they are pointing in the same direction.
         if cos_angle > 0
         {
            // standard rotation
            self = .identity
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

            self = Self (ix: t [0], iy: t [1], iz: t [2], r: 0);
         }
      }
      else
      {
         // Vectors are not parallel
         // The abs () wrapping is to avoid problems when `dot' "overflows" a tiny wee bit,
         // which can lead to sqrt () returning NaN.
         crossvec *= sqrt (abs (1 - cos_angle) / 2)
         
         self = Self (ix: crossvec [0],
                      iy: crossvec [1],
                      iz: crossvec [2],
                      r: sqrt (abs (1 + cos_angle) / 2))
      }
   }
   
   public var axis : Vector3f
   {
      if abs (real) > 1
      {
         return Vector3f .zAxis
      }
      else
      {
         let angle = acos (real) * 2
         let scale = sin (angle / 2)

         if scale == 0
         {
            return Vector3f .zAxis
         }
         else
         {
            return imag / scale
         }
      }
   }
   
   public var normalized : Quaternion4f
   {
      let l = length
            
      if l != 0
      {
         return self / l
      }
      
      return Self ()
   }
}

// Normalize

public func normalize (_ quat : Quaternion4d) -> Quaternion4d
{
   return quat .normalized
}

public func normalize (_ quat : Quaternion4f) -> Quaternion4f
{
   return quat .normalized
}
