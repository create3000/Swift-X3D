//
//  Matrix.swift
//  X3D
//
//  Created by Holger Seelig on 05.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public typealias Matrix2d = simd_double2x2
public typealias Matrix2f = simd_float2x2
public typealias Matrix3d = simd_double3x3
public typealias Matrix3f = simd_float3x3
public typealias Matrix4d = simd_double4x4
public typealias Matrix4f = simd_float4x4

// Extensions

extension Matrix2d
{
   public static let identity = matrix_identity_double2x2
   
   public var xAxis  : Double { self [0] [0] }
   public var origin : Double { self [1] [0] }
}

extension Matrix2f
{
   public static let identity = matrix_identity_float2x2
   
   public var xAxis  : Float { self [0] [0] }
   public var origin : Float { self [1] [0] }
}

extension Matrix3d
{
   public static let identity = matrix_identity_double3x3
   
   public init (_ rotation : Rotation4d)
   {
      self .init (rotation .quat)
   }
   
   public init (_ rotation : Double)
   {
      let sinAngle = sin (rotation)
      let cosAngle = cos (rotation)
      
      self .init (columns: (Vector3d ( cosAngle, sinAngle, 0),
                            Vector3d (-sinAngle, cosAngle, 0),
                            Vector3d (0, 0, 1)))
   }
   
   public var xAxis  : Vector2d { Vector2d (self [0] [0], self [0] [1]) }
   public var yAxis  : Vector2d { Vector2d (self [1] [0], self [1] [1]) }
   public var origin : Vector2d { Vector2d (self [2] [0], self [2] [1]) }

   public var submatrix : Matrix2d
   {
      let c0 = columns .0
      let c1 = columns .1

      return Matrix2d (columns: (
         Vector2d (c0 .x, c0 .y),
         Vector2d (c1 .x, c1 .y)
      ))
   }
}

extension Matrix3f
{
   public static let identity = matrix_identity_float3x3
   
   public init (_ rotation : Rotation4f)
   {
      self .init (rotation .quat)
   }
   
   public init (_ rotation : Float)
   {
      let sinAngle = sin (rotation)
      let cosAngle = cos (rotation)
      
      self .init (columns: (Vector3f ( cosAngle, sinAngle, 0),
                            Vector3f (-sinAngle, cosAngle, 0),
                            Vector3f (0, 0, 1)))
   }

   public var xAxis  : Vector2f { Vector2f (self [0] [0], self [0] [1]) }
   public var yAxis  : Vector2f { Vector2f (self [1] [0], self [1] [1]) }
   public var origin : Vector2f { Vector2f (self [2] [0], self [2] [1]) }

   public var submatrix : Matrix2f
   {
      let c0 = columns .0
      let c1 = columns .1

      return Matrix2f (columns: (
         Vector2f (c0 .x, c0 .y),
         Vector2f (c1 .x, c1 .y)
      ))
   }
}

extension Matrix4d
{
   public static let identity = matrix_identity_double4x4
   
   public init (_ rotation : Rotation4d)
   {
      self .init (rotation .quat)
   }
   
   public var xAxis  : Vector3d { Vector3d (self [0] [0], self [0] [1], self [0] [2]) }
   public var yAxis  : Vector3d { Vector3d (self [1] [0], self [1] [1], self [1] [2]) }
   public var zAxis  : Vector3d { Vector3d (self [2] [0], self [2] [1], self [2] [2]) }
   public var origin : Vector3d { Vector3d (self [3] [0], self [3] [1], self [3] [2]) }

   public var submatrix : Matrix3d
   {
      let c0 = columns .0
      let c1 = columns .1
      let c2 = columns .2

      return Matrix3d (columns: (
         Vector3d (c0 .x, c0 .y, c0 .z),
         Vector3d (c1 .x, c1 .y, c1 .z),
         Vector3d (c2 .x, c2 .y, c2 .z)
      ))
   }
}

extension Matrix4f
{
   public static let identity = matrix_identity_float4x4
   
   public init (_ rotation : Rotation4f)
   {
      self .init (rotation .quat)
   }
   
   public var xAxis  : Vector3f { Vector3f (self [0] [0], self [0] [1], self [0] [2]) }
   public var yAxis  : Vector3f { Vector3f (self [1] [0], self [1] [1], self [1] [2]) }
   public var zAxis  : Vector3f { Vector3f (self [2] [0], self [2] [1], self [2] [2]) }
   public var origin : Vector3f { Vector3f (self [3] [0], self [3] [1], self [3] [2]) }

   public var submatrix : Matrix3f
   {
      let c0 = columns .0
      let c1 = columns .1
      let c2 = columns .2

      return Matrix3f (columns: (
         Vector3f (c0 .x, c0 .y, c0 .z),
         Vector3f (c1 .x, c1 .y, c1 .z),
         Vector3f (c2 .x, c2 .y, c2 .z)
      ))
   }
   
   public func translate (_ translation : Vector3f) -> Matrix4f
   {
      let translationMatrix = Matrix4f (columns: (Vector4f (1, 0, 0, 0),
                                                  Vector4f (0, 1, 0, 0),
                                                  Vector4f (0, 0, 1, 0),
                                                  Vector4f (translation .x, translation .y, translation .z, 1)))
      
      return self * translationMatrix
   }
   
   public func rotate (_ rotation : Rotation4f) -> Matrix4f
   {
      return self * Matrix4f (rotation)
   }
   
   public func scale (_ scale : Vector3f) -> Matrix4f
   {
      let scaleMatrix = Matrix4f (columns: (Vector4f (scale .x, 0, 0, 0),
                                            Vector4f (0, scale .y, 0, 0),
                                            Vector4f (0, 0, scale .z, 0),
                                            Vector4f (0, 0, 0, 1)))
      
      return self * scaleMatrix
   }
}

// ! Matrix2

@inlinable
public func transpose (_ matrix : Matrix2d) -> Matrix2d
{
   return matrix .transpose
}

@inlinable
public prefix func ! (_ matrix : Matrix2d) -> Matrix2d
{
   return matrix .transpose
}

@inlinable
public func transpose (_ matrix : Matrix2f) -> Matrix2f
{
   return matrix .transpose
}

@inlinable
public prefix func ! (_ matrix : Matrix2f) -> Matrix2f
{
   return matrix .transpose
}

// ! Matrix3

@inlinable
public func transpose (_ matrix : Matrix3d) -> Matrix3d
{
   return matrix .transpose
}

@inlinable
public prefix func ! (_ matrix : Matrix3d) -> Matrix3d
{
   return matrix .transpose
}

@inlinable
public func transpose (_ matrix : Matrix3f) -> Matrix3f
{
   return matrix .transpose
}

@inlinable
public prefix func ! (_ matrix : Matrix3f) -> Matrix3f
{
   return matrix .transpose
}

// ! Matrix4

@inlinable
public func transpose (_ matrix : Matrix4d) -> Matrix4d
{
   return matrix .transpose
}

@inlinable
public prefix func ! (_ matrix : Matrix4d) -> Matrix4d
{
   return matrix .transpose
}

@inlinable
public func transpose (_ matrix : Matrix4f) -> Matrix4f
{
   return matrix .transpose
}

@inlinable
public prefix func ! (_ matrix : Matrix4f) -> Matrix4f
{
   return matrix .transpose
}

// ~ Matrix2

@inlinable
public func inverse (_ matrix : Matrix2d) -> Matrix2d
{
   return matrix .inverse
}

@inlinable
public prefix func ~ (_ matrix : Matrix2d) -> Matrix2d
{
   return matrix .inverse
}

@inlinable
public func inverse (_ matrix : Matrix2f) -> Matrix2f
{
   return matrix .inverse
}

@inlinable
public prefix func ~ (_ matrix : Matrix2f) -> Matrix2f
{
   return matrix .inverse
}

// ~ Matrix3

@inlinable
public func inverse (_ matrix : Matrix3d) -> Matrix3d
{
   return matrix .inverse
}

@inlinable
public prefix func ~ (_ matrix : Matrix3d) -> Matrix3d
{
   return matrix .inverse
}

@inlinable
public func inverse (_ matrix : Matrix3f) -> Matrix3f
{
   return matrix .inverse
}

@inlinable
public prefix func ~ (_ matrix : Matrix3f) -> Matrix3f
{
   return matrix .inverse
}

// ~ Matrix4

@inlinable
public func inverse (_ matrix : Matrix4d) -> Matrix4d
{
   return matrix .inverse
}

@inlinable
public prefix func ~ (_ matrix : Matrix4d) -> Matrix4d
{
   return matrix .inverse
}

@inlinable
public func inverse (_ matrix : Matrix4f) -> Matrix4f
{
   return matrix .inverse
}

@inlinable
public prefix func ~ (_ matrix : Matrix4f) -> Matrix4f
{
   return matrix .inverse
}

// Vector2 * Matrix3

@inlinable
public func * (_ vector : Vector2d, matrix : Matrix3d) -> Vector2d
{
   let result = Vector3d (vector, 1) * matrix
   
   return Vector2d (result .x, result .y) / result .z
}

@inlinable
public func * (_ vector : Vector2f, matrix : Matrix3f) -> Vector2f
{
   let result = Vector3f (vector, 1) * matrix

   return Vector2f (result .x, result .y) / result .z
}

// Vector3 * Matrix4

@inlinable
public func * (_ vector : Vector3d, matrix : Matrix4d) -> Vector3d
{
   let result = Vector4d (vector, 1) * matrix
   
   return Vector3d (result .x, result .y, result .z) / result .w
}

@inlinable
public func * (_ vector : Vector3f, matrix : Matrix4f) -> Vector3f
{
   let result = Vector4f (vector, 1) * matrix

   return Vector3f (result .x, result .y, result .z) / result .w
}

// Matrix3 * Vector2

@inlinable
public func * (_ matrix : Matrix3d, vector : Vector2d) -> Vector2d
{
   let result = matrix * Vector3d (vector, 1)
   
   return Vector2d (result .x, result .y) / result .z
}

@inlinable
public func * (_ matrix : Matrix3f, vector : Vector2f) -> Vector2f
{
   let result = matrix * Vector3f (vector, 1)
   
   return Vector2f (result .x, result .y) / result .z
}

// Matrix4 * Vector3

@inlinable
public func * (_ matrix : Matrix4d, vector : Vector3d) -> Vector3d
{
   let result = matrix * Vector4d (vector, 1)
   
   return Vector3d (result .x, result .y, result .z) / result .w
}

@inlinable
public func * (_ matrix : Matrix4f, vector : Vector3f) -> Vector3f
{
   let result = matrix * Vector4f (vector, 1)
   
   return Vector3f (result .x, result .y, result .z) / result .w
}

// Rotation4 * Matrix3

@inlinable
public func * (_ rotation : Rotation4d, matrix : Matrix3d) -> Matrix3d
{
   return Matrix3d (rotation) * matrix
}

@inlinable
public func * (_ rotation : Rotation4f, matrix : Matrix3f) -> Matrix3f
{
   return Matrix3f (rotation) * matrix
}

// Rotation4 * Matrix4

@inlinable
public func * (_ rotation : Rotation4d, matrix : Matrix4d) -> Matrix4d
{
   return Matrix4d (rotation) * matrix
}

@inlinable
public func * (_ rotation : Rotation4f, matrix : Matrix4f) -> Matrix4f
{
   return Matrix4f (rotation) * matrix
}

// Matrix3 * Rotation4

@inlinable
public func * (_ matrix : Matrix3d, rotation : Rotation4d) -> Matrix3d
{
   return matrix * Matrix3d (rotation)
}

@inlinable
public func * (_ matrix : Matrix3f, rotation : Rotation4f) -> Matrix3f
{
   return matrix * Matrix3f (rotation)
}

// Matrix4 * Rotation4

@inlinable
public func * (_ matrix : Matrix4d, rotation : Rotation4d) -> Matrix4d
{
   return matrix * Matrix4d (rotation)
}

@inlinable
public func * (_ matrix : Matrix4f, rotation : Rotation4f) -> Matrix4f
{
   return matrix * Matrix4f (rotation)
}

// submatrix (Matrix3)

@inlinable
public func submatrix (_ matrix : Matrix3d) -> Matrix2d
{
   return matrix .submatrix
}

@inlinable
public func submatrix (_ matrix : Matrix3f) -> Matrix2f
{
   return matrix .submatrix
}

// submatrix (Matrix4)

@inlinable
public func submatrix (_ matrix : Matrix4d) -> Matrix3d
{
   return matrix .submatrix
}

@inlinable
public func submatrix (_ matrix : Matrix4f) -> Matrix3f
{
   return matrix .submatrix
}

// Operations

public func compose_transformation_matrix (translation : Vector2d = .zero,
                                           rotation : Double = 0,
                                           scale : Vector2d = .one,
                                           scaleOrientation : Double = 0,
                                           center : Vector2d = .zero) -> Matrix3d
{
   var matrix = Matrix3d .identity

   matrix [2, 0] = translation .x
   matrix [2, 1] = translation .y

   var centerMatrix = Matrix3d .identity

   if center != .zero
   {
      centerMatrix [2, 0] = center .x
      centerMatrix [2, 1] = center .y

      matrix *= centerMatrix
   }

   if rotation != 0
   {
      matrix *= Matrix3d (rotation)
   }

   if scale != .one
   {
      var scaleMatrix = Matrix3d .identity

      scaleMatrix [0, 0] = scale .x
      scaleMatrix [1, 1] = scale .y
      
      if scaleOrientation != 0
      {
         let scaleOrientaionMatrix1 = Matrix3d (scaleOrientation)
         let scaleOrientaionMatrix2 = Matrix3d (-scaleOrientation)

         matrix *= scaleOrientaionMatrix1
         matrix *= scaleMatrix
         matrix *= scaleOrientaionMatrix2
      }
      else
      {
         matrix *= scaleMatrix
      }
   }
   
   if center != .zero
   {
      centerMatrix [2, 0] = -center .x
      centerMatrix [2, 1] = -center .y

      matrix *= centerMatrix
   }

   return matrix
}

public func compose_transformation_matrix (translation : Vector2f = .zero,
                                           rotation : Float = 0,
                                           scale : Vector2f = .one,
                                           scaleOrientation : Float = 0,
                                           center : Vector2f = .zero) -> Matrix3f
{
   var matrix = Matrix3f .identity

   matrix [2, 0] = translation .x
   matrix [2, 1] = translation .y

   var centerMatrix = Matrix3f .identity

   if center != .zero
   {
      centerMatrix [2, 0] = center .x
      centerMatrix [2, 1] = center .y

      matrix *= centerMatrix
   }

   if rotation != 0
   {
      matrix *= Matrix3f (rotation)
   }

   if scale != .one
   {
      var scaleMatrix = Matrix3f .identity

      scaleMatrix [0, 0] = scale .x
      scaleMatrix [1, 1] = scale .y
      
      if scaleOrientation != 0
      {
         let scaleOrientaionMatrix1 = Matrix3f (scaleOrientation)
         let scaleOrientaionMatrix2 = Matrix3f (-scaleOrientation)

         matrix *= scaleOrientaionMatrix1
         matrix *= scaleMatrix
         matrix *= scaleOrientaionMatrix2
      }
      else
      {
         matrix *= scaleMatrix
      }
   }
   
   if center != .zero
   {
      centerMatrix [2, 0] = -center .x
      centerMatrix [2, 1] = -center .y

      matrix *= centerMatrix
   }

   return matrix
}

public func compose_transformation_matrix (translation : Vector3d = .zero,
                                           rotation : Rotation4d = .identity,
                                           scale : Vector3d = .one,
                                           scaleOrientation : Rotation4d = .identity,
                                           center : Vector3d = .zero) -> Matrix4d
{
   var matrix = Matrix4d .identity

   matrix [3, 0] = translation .x
   matrix [3, 1] = translation .y
   matrix [3, 2] = translation .z

   var centerMatrix = Matrix4d .identity

   if center != .zero
   {
      centerMatrix [3, 0] = center .x
      centerMatrix [3, 1] = center .y
      centerMatrix [3, 2] = center .z

      matrix *= centerMatrix
   }

   if rotation != .identity
   {
      matrix *= Matrix4d (rotation)
   }

   if scale != .one
   {
      var scaleMatrix = Matrix4d .identity

      scaleMatrix [0, 0] = scale .x
      scaleMatrix [1, 1] = scale .y
      scaleMatrix [2, 2] = scale .z
      
      if scaleOrientation != .identity
      {
         let scaleOrientaionMatrix1 = Matrix4d (scaleOrientation)
         let scaleOrientaionMatrix2 = Matrix4d (scaleOrientation .inverse)

         matrix *= scaleOrientaionMatrix1
         matrix *= scaleMatrix
         matrix *= scaleOrientaionMatrix2
      }
      else
      {
         matrix *= scaleMatrix
      }
   }
   
   if center != .zero
   {
      centerMatrix [3, 0] = -center .x
      centerMatrix [3, 1] = -center .y
      centerMatrix [3, 2] = -center .z

      matrix *= centerMatrix
   }

   return matrix
}

public func compose_transformation_matrix (translation : Vector3f = .zero,
                                           rotation : Rotation4f = .identity,
                                           scale : Vector3f = .one,
                                           scaleOrientation : Rotation4f = .identity,
                                           center : Vector3f = .zero) -> Matrix4f
{
   var matrix = Matrix4f .identity

   matrix [3, 0] = translation .x
   matrix [3, 1] = translation .y
   matrix [3, 2] = translation .z

   var centerMatrix = Matrix4f .identity

   if center != .zero
   {
      centerMatrix [3, 0] = center .x
      centerMatrix [3, 1] = center .y
      centerMatrix [3, 2] = center .z

      matrix *= centerMatrix
   }

   if rotation != .identity
   {
      matrix *= Matrix4f (rotation)
   }

   if scale != .one
   {
      var scaleMatrix = Matrix4f .identity

      scaleMatrix [0, 0] = scale .x
      scaleMatrix [1, 1] = scale .y
      scaleMatrix [2, 2] = scale .z
      
      if scaleOrientation != .identity
      {
         let scaleOrientaionMatrix1 = Matrix4f (scaleOrientation)
         let scaleOrientaionMatrix2 = Matrix4f (scaleOrientation .inverse)

         matrix *= scaleOrientaionMatrix1
         matrix *= scaleMatrix
         matrix *= scaleOrientaionMatrix2
      }
      else
      {
         matrix *= scaleMatrix
      }
   }
   
   if center != .zero
   {
      centerMatrix [3, 0] = -center .x
      centerMatrix [3, 1] = -center .y
      centerMatrix [3, 2] = -center .z

      matrix *= centerMatrix
   }

   return matrix
}

public func decompose_transformation_matrix (_ matrix : Matrix3d, center : Vector2d) -> (translation : Vector2d, rotation : Double, scale : Vector2d, scaleOrientation : Double)
{
   var centerMatrix1 = Matrix3d .identity
   var centerMatrix2 = Matrix3d .identity

   centerMatrix1 [2, 0] = -center .x
   centerMatrix1 [2, 1] = -center .y

   centerMatrix2 [2, 0] = center .x
   centerMatrix2 [2, 1] = center .y

   return decompose_transformation_matrix (centerMatrix1 * matrix * centerMatrix2)
}

public func decompose_transformation_matrix (_ matrix : Matrix3d) -> (translation : Vector2d, rotation : Double, scale : Vector2d, scaleOrientation : Double)
{
   // (1) Get translation.
   let translation = Vector2d (matrix [2] [0], matrix [2] [1])
   
   // (2) Create 3x3 matrix. Transpose column base matrix to row based matrix.
   let a = !matrix .submatrix

   // (3) Compute det A. If negative, set sign = -1, else sign = 1
   let det      = a .determinant
   let det_sign = Double (det < 0 ? -1 : 1)

   if det == 0
   {
      return (.zero, 0, .one, 0) // singular
   }

   // (4) B = A * !A  (here !A means A transpose)
   let b = a * !a
   var m =  [[Double]] ()
   
   for c in 0 ..< 2
   {
      m .append ([Double] (repeating: 0, count: 2))
      
      for r in 0 ..< 2
      {
         m [c] [r] = b [c] [r]
      }
   }

   var evalues  : [Double]   = []
   var evectors : [[Double]] = []

   eigen_decomposition (order: 2, matrix: m, values: &evalues, vectors: &evectors)
   
   // find min / max eigenvalues and do ratio test to determine singularity

   let scaleOrientation = Matrix2d (columns: (Vector2d (evectors [0] [0], evectors [0] [1]),
                                              Vector2d (evectors [1] [0], evectors [1] [1])))

   // Compute s = sqrt(evalues), with sign. Set si = s-inverse
   var si    = Matrix2d ()
   var scale = Vector2d ()

   for i in 0 ..< 2
   {
      scale [i]  = det_sign * sqrt (evalues [i])
      si [i] [i] = 1 / scale [i]
   }

   // (5) Compute U = !R ~S R A.
   let rotation = !(scaleOrientation * si * !scaleOrientation * a)

   // Transpose rotation and scale-orientation to column based matrix.
   return (translation, atan2 (rotation [0, 1], rotation [0, 0]), scale, atan2 (scaleOrientation [0, 1], scaleOrientation [0, 0]))
}

public func decompose_transformation_matrix (_ matrix : Matrix3f, center : Vector2f) -> (translation : Vector2f, rotation : Float, scale : Vector2f, scaleOrientation : Float)
{
   var centerMatrix1 = Matrix3f .identity
   var centerMatrix2 = Matrix3f .identity

   centerMatrix1 [2, 0] = -center .x
   centerMatrix1 [2, 1] = -center .y

   centerMatrix2 [2, 0] = center .x
   centerMatrix2 [2, 1] = center .y

   return decompose_transformation_matrix (centerMatrix1 * matrix * centerMatrix2)
}

public func decompose_transformation_matrix (_ matrix : Matrix3f) -> (translation : Vector2f, rotation : Float, scale : Vector2f, scaleOrientation : Float)
{
   // (1) Get translation.
   let translation = Vector2f (matrix [2] [0], matrix [2] [1])
   
   // (2) Create 3x3 matrix. Transpose column base matrix to row based matrix.
   let a = !matrix .submatrix

   // (3) Compute det A. If negative, set sign = -1, else sign = 1
   let det      = a .determinant
   let det_sign = Float (det < 0 ? -1 : 1)

   if det == 0
   {
      return (.zero, 0, .one, 0) // singular
   }

   // (4) B = A * !A  (here !A means A transpose)
   let b = a * !a
   var m =  [[Float]] ()
   
   for c in 0 ..< 2
   {
      m .append ([Float] (repeating: 0, count: 2))
      
      for r in 0 ..< 2
      {
         m [c] [r] = b [c] [r]
      }
   }

   var evalues  : [Float]   = []
   var evectors : [[Float]] = []

   eigen_decomposition (order: 2, matrix: m, values: &evalues, vectors: &evectors)
   
   // find min / max eigenvalues and do ratio test to determine singularity

   let scaleOrientation = Matrix2f (columns: (Vector2f (evectors [0] [0], evectors [0] [1]),
                                              Vector2f (evectors [1] [0], evectors [1] [1])))

   // Compute s = sqrt(evalues), with sign. Set si = s-inverse
   var si    = Matrix2f ()
   var scale = Vector2f ()

   for i in 0 ..< 2
   {
      scale [i]  = det_sign * sqrt (evalues [i])
      si [i] [i] = 1 / scale [i]
   }

   // (5) Compute U = !R ~S R A.
   let rotation = !(scaleOrientation * si * !scaleOrientation * a)

   // Transpose rotation and scale-orientation to column based matrix.
   return (translation, atan2 (rotation [0, 1], rotation [0, 0]), scale, atan2 (scaleOrientation [0, 1], scaleOrientation [0, 0]))
}

public func decompose_transformation_matrix (_ matrix : Matrix4d, center : Vector3d) -> (translation : Vector3d, rotation : Rotation4d, scale : Vector3d, scaleOrientation : Rotation4d)
{
   var centerMatrix1 = Matrix4d .identity
   var centerMatrix2 = Matrix4d .identity

   centerMatrix1 [3, 0] = -center .x
   centerMatrix1 [3, 1] = -center .y
   centerMatrix1 [3, 2] = -center .z

   centerMatrix2 [3, 0] = center .x
   centerMatrix2 [3, 1] = center .y
   centerMatrix2 [3, 2] = center .z

   return decompose_transformation_matrix (centerMatrix1 * matrix * centerMatrix2)
}

public func decompose_transformation_matrix (_ matrix : Matrix4d) -> (translation : Vector3d, rotation : Rotation4d, scale : Vector3d, scaleOrientation : Rotation4d)
{
   // (1) Get translation.
   let translation = Vector3d (matrix [3] [0], matrix [3] [1], matrix [3] [2])
   
   // (2) Create 3x3 matrix. Transpose column base matrix to row based matrix.
   let a = !matrix .submatrix

   // (3) Compute det A. If negative, set sign = -1, else sign = 1
   let det      = a .determinant
   let det_sign = Double (det < 0 ? -1 : 1)

   if det == 0
   {
      return (.zero, .identity, .one, .identity) // singular
   }

   // (4) B = A * !A  (here !A means A transpose)
   let b = a * !a
   var m =  [[Double]] ()
   
   for c in 0 ..< 3
   {
      m .append ([Double] (repeating: 0, count: 3))
      
      for r in 0 ..< 3
      {
         m [c] [r] = b [c] [r]
      }
   }

   var evalues  : [Double]   = []
   var evectors : [[Double]] = []

   eigen_decomposition (order: 3, matrix: m, values: &evalues, vectors: &evectors)
   
   // find min / max eigenvalues and do ratio test to determine singularity

   let scaleOrientation = Matrix3d (columns: (Vector3d (evectors [0] [0], evectors [0] [1], evectors [0] [2]),
                                              Vector3d (evectors [1] [0], evectors [1] [1], evectors [1] [2]),
                                              Vector3d (evectors [2] [0], evectors [2] [1], evectors [2] [2])))

   // Compute s = sqrt(evalues), with sign. Set si = s-inverse
   var si    = Matrix3d ()
   var scale = Vector3d ()

   for i in 0 ..< 3
   {
      scale [i]  = det_sign * sqrt (evalues [i])
      si [i] [i] = 1 / scale [i]
   }

   // (5) Compute U = !R ~S R A.
   let rotation = scaleOrientation * si * !scaleOrientation * a

   // Transpose rotation and scale-orientation to column based matrix.
   return (translation, Rotation4d (!rotation), scale, Rotation4d (scaleOrientation))
}

public func decompose_transformation_matrix (_ matrix : Matrix4f, center : Vector3f) -> (translation : Vector3f, rotation : Rotation4f, scale : Vector3f, scaleOrientation : Rotation4f)
{
   var centerMatrix1 = Matrix4f .identity
   var centerMatrix2 = Matrix4f .identity

   centerMatrix1 [3, 0] = -center .x
   centerMatrix1 [3, 1] = -center .y
   centerMatrix1 [3, 2] = -center .z

   centerMatrix2 [3, 0] = center .x
   centerMatrix2 [3, 1] = center .y
   centerMatrix2 [3, 2] = center .z

   return decompose_transformation_matrix (centerMatrix1 * matrix * centerMatrix2)
}

public func decompose_transformation_matrix (_ matrix : Matrix4f) -> (translation : Vector3f, rotation : Rotation4f, scale : Vector3f, scaleOrientation : Rotation4f)
{
   // (1) Get translation.
   let translation = Vector3f (matrix [3] [0], matrix [3] [1], matrix [3] [2])
   
   // (2) Create 3x3 matrix. Transpose column base matrix to row based matrix.
   let a = !matrix .submatrix

   // (3) Compute det A. If negative, set sign = -1, else sign = 1
   let det      = a .determinant
   let det_sign = Float (det < 0 ? -1 : 1)

   if det == 0
   {
      return (.zero, .identity, .one, .identity) // singular
   }

   // (4) B = A * !A  (here !A means A transpose)
   let b = a * !a
   var m =  [[Float]] ()
   
   for c in 0 ..< 3
   {
      m .append ([Float] (repeating: 0, count: 3))
      
      for r in 0 ..< 3
      {
         m [c] [r] = b [c] [r]
      }
   }

   var evalues  : [Float]   = []
   var evectors : [[Float]] = []

   eigen_decomposition (order: 3, matrix: m, values: &evalues, vectors: &evectors)
   
   // find min / max eigenvalues and do ratio test to determine singularity

   let scaleOrientation = Matrix3f (columns: (Vector3f (evectors [0] [0], evectors [0] [1], evectors [0] [2]),
                                              Vector3f (evectors [1] [0], evectors [1] [1], evectors [1] [2]),
                                              Vector3f (evectors [2] [0], evectors [2] [1], evectors [2] [2])))

   // Compute s = sqrt(evalues), with sign. Set si = s-inverse
   var si    = Matrix3f ()
   var scale = Vector3f ()

   for i in 0 ..< 3
   {
      scale [i]  = det_sign * sqrt (evalues [i])
      si [i] [i] = 1 / scale [i]
   }

   // (5) Compute U = !R ~S R A.
   let rotation = scaleOrientation * si * !scaleOrientation * a

   // Transpose rotation and scale-orientation to column based matrix.
   return (translation, Rotation4f (!rotation), scale, Rotation4f (scaleOrientation))
}

fileprivate func eigen_decomposition <T : FloatingPoint> (order : Int, matrix : [[T]], values : inout [T], vectors : inout [[T]])
{
   var a : [[T]] = [ ] // more scratch
   var b : [T]   = [ ] // more scratch
   var z : [T]   = [ ] // more scratch
   
   var sm     : T = 0 // smallest entry
   var theta  : T = 0 // angle for Jacobi rotation
   var c      : T = 0
   var s      : T = 0
   var t      : T = 0 // cosine, sine, tangent of theta
   var tau    : T = 0 // sine / (1 + cos)
   var h      : T = 0
   var g      : T = 0 // two scrap values
   var thresh : T = 0 // threshold below which no rotation done
   
   let size = order * order

   // initializations
   for _ in 0 ..< order
   {
      a .append ([T] (repeating: 0, count: order))
      vectors .append ([T] (repeating: 0, count: order))
   }
   
   b .append (contentsOf: [T] (repeating: 0, count: order))
   z .append (contentsOf: [T] (repeating: 0, count: order))
   values .append (contentsOf: [T] (repeating: 0, count: order))

   for i in 0 ..< order
   {
      values [i] = matrix [i] [i]
      b [i]      = matrix [i] [i]
      z [i]      = 0

      for j in 0 ..< order
      {
         vectors [i] [j] = i == j ? 1 : 0
         a [i] [j] = matrix [j] [i]
      }
   }

   // Why 50? I don't know--it's the way the folks who wrote the
   // algorithm did it:
   for i in 0 ..< 50
   {
      sm = 0

      for p in 0 ..< order - 1
      {
         for q in p + 1 ..< order
         {
            sm += abs (a [p] [q])
         }
      }

      if sm == 0
      {
         break
      }

      thresh = i < 3 ? (sm / T (size)) / 5 : 0

      for p in 0 ..<  order - 1
      {
         for q in p + 1 ..<  order
         {
            g = 100 * abs (a [p] [q])

            if i > 3
               && (abs (values [p]) + g == abs (values [p]))
               && (abs (values [q]) + g == abs (values [q]))
            {
               a [p] [q] = 0
            }

            else if abs (a [p] [q]) > thresh
            {
               h = values [q] - values [p]

               if abs (h) + g == abs (h)
               {
                  t = a [p] [q] / h
               }
               else
               {
                  theta = (h / a [p] [q]) / 2
                  t     = 1 / (abs (theta) + sqrt (1 + theta * theta))

                  if theta < 0 { t = -t }
               }
               // End of computing tangent of rotation angle

               c           = 1 / sqrt (1 + t * t)
               s           = t * c
               tau         = s / (1 + c)
               h           = t * a [p] [q]
               z [p]      -= h
               z [q]      += h
               values [p] -= h
               values [q] += h
               a [p] [q]   = 0

               for j in 0 ..< p
               {
                  g = a [j] [p]
                  h = a [j] [q]
                  a [j] [p] = g - s * (h + g * tau)
                  a [j] [q] = h + s * (g - h * tau)
               }

               for j in p + 1 ..< q
               {
                  g = a [p] [j]
                  h = a [j] [q]
                  a [p] [j] = g - s * (h + g * tau)
                  a [j] [q] = h + s * (g - h * tau)
               }

               for j in q + 1 ..< order
               {
                  g = a [p] [j]
                  h = a [q] [j]
                  a [p] [j] = g - s * (h + g * tau)
                  a [q] [j] = h + s * (g - h * tau)
               }

               for j in 0 ..< order
               {
                  g = vectors [j] [p]
                  h = vectors [j] [q]
                  vectors [j] [p] = g - s * (h + g * tau)
                  vectors [j] [q] = h + s * (g - h * tau)
               }
            }
         }
      }

      for p in 0 ..< order
      {
         b [p]     += z [p]
         values [p] = b [p]
         z [p]      = 0
      }
   }
}
