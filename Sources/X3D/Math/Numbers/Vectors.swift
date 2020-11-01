//
//  Vector3.swift
//  X3D
//
//  Created by Holger Seelig on 04.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import simd

public typealias Vector2d = simd_double2
public typealias Vector2f = simd_float2
public typealias Vector3d = simd_double3
public typealias Vector3f = simd_float3
public typealias Vector4d = simd_double4
public typealias Vector4f = simd_float4
public typealias Vector4i = simd_int4

// Extensions

extension Vector2d
{
   public static let xAxis = Vector2d (1, 0)
   public static let yAxis = Vector2d (0, 1)
}

extension Vector2f
{
   public static let xAxis = Vector2f (1, 0)
   public static let yAxis = Vector2f (0, 1)
}

extension Vector3d
{
   public static let xAxis = Vector3d (1, 0, 0)
   public static let yAxis = Vector3d (0, 1, 0)
   public static let zAxis = Vector3d (0, 0, 1)
}

extension Vector3f
{
   public static let xAxis = Vector3f (1, 0, 0)
   public static let yAxis = Vector3f (0, 1, 0)
   public static let zAxis = Vector3f (0, 0, 1)
}

extension Vector4d
{
   public static let xAxis = Vector4d (1, 0, 0, 0)
   public static let yAxis = Vector4d (0, 1, 0, 0)
   public static let zAxis = Vector4d (0, 0, 1, 0)
   public static let wAxis = Vector4d (0, 0, 0, 1)
}

extension Vector4f
{
   public static let xAxis = Vector4f (1, 0, 0, 0)
   public static let yAxis = Vector4f (0, 1, 0, 0)
   public static let zAxis = Vector4f (0, 0, 1, 0)
   public static let wAxis = Vector4f (0, 0, 0, 1)
}

// Save normalize

public func normalize (_ vector : Vector2d) -> Vector2d
{
   let l = length (vector)
   
   if l > 0
   {
      return vector / l
   }
   
   return Vector2d ()
}

public func normalize (_ vector : Vector2f) -> Vector2f
{
   let l = length (vector)
   
   if l > 0
   {
      return vector / l
   }
   
   return Vector2f ()
}

public func normalize (_ vector : Vector3d) -> Vector3d
{
   let l = length (vector)
   
   if l > 0
   {
      return vector / l
   }
   
   return Vector3d ()
}

public func normalize (_ vector : Vector3f) -> Vector3f
{
   let l = length (vector)
   
   if l > 0
   {
      return vector / l
   }
   
   return Vector3f ()
}

public func normalize (_ vector : Vector4d) -> Vector4d
{
   let l = length (vector)
   
   if l > 0
   {
      return vector / l
   }
   
   return Vector4d ()
}

public func normalize (_ vector : Vector4f) -> Vector4f
{
   let l = length (vector)
   
   if l > 0
   {
      return vector / l
   }
   
   return Vector4f ()
}

// Spherical linear interpolate normal vectors

public func slerp (_ from : Vector3f, _ to : Vector3f, t : Float) -> Vector3f
{
   let q0     = Quaternion4f (real: 0, imag: from)
   let q1     = Quaternion4f (real: 0, imag: to)
   let result = simd_slerp (q0, q1, t)
   
   return result .imag
}

// Normal generation for triangles

public func normal (_ A : Vector3d,
                    _ B : Vector3d,
                    _ C : Vector3d) -> Vector3d
{
   return normalize (cross (C - B, A - B))
}

public func normal (_ A : Vector3f,
                    _ B : Vector3f,
                    _ C : Vector3f) -> Vector3f
{
   return normalize (cross (C - B, A - B))
}

// Normal generation for quads

public func normal (_ A : Vector3d,
                    _ B : Vector3d,
                    _ C : Vector3d,
                    _ D : Vector3d) -> Vector3d
{
   return normalize (cross (C - A, D - B))
}

public func normal (_ A : Vector3f,
                    _ B : Vector3f,
                    _ C : Vector3f,
                    _ D : Vector3f) -> Vector3f
{
   return normalize (cross (C - A, D - B))
}
