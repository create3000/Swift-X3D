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
}

extension Quaternion4f
{
   public static let identity = Quaternion4f (ix: 0, iy: 0, iz: 0, r: 1)
   
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
}
