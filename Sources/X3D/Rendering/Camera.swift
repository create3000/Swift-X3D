//
//  Camera.swift
//  X3D
//
//  Created by Holger Seelig on 12.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class Camera
{
   /// Creates an othographic projection matrix.
   /// * parameters:
   ///   * left: Specify the coordinates for the left vertical clipping plane.
   ///   * right: Specify the coordinates for the left vertical clipping plane.
   ///   * bottom : Specify the coordinates for the bottom horizontal clipping plane.
   ///   * top: Specify the coordinates for the bottom horizontal clipping plane.
   ///   * nearValue: Specify the distances to the nearer depth clipping plane. This value must be positive.
   ///   * farValue: Specify the distances to the farther depth clipping plane. This value must be positive.
   static func ortho (left : Float, right : Float, bottom : Float, top : Float, nearValue : Float, farValue : Float) -> Matrix4f
   {
      let r_l = right - left
      let t_b = top - bottom
      let f_n = farValue - nearValue
   
      let A =  2 / r_l
      let B =  2 / t_b
      let C = -1 / f_n
      let D = -(right + left) / r_l
      let E = -(top + bottom) / t_b
      let F = -farValue / f_n + 1

      return Matrix4f (columns: (
         Vector4f (A, 0, 0, 0),
         Vector4f (0, B, 0, 0),
         Vector4f (0, 0, C, 0),
         Vector4f (D, E, F, 1)
      ))
   }
   
   /// Creates an perspective projection matrix.
   /// * parameters:
   ///   * fieldOfView: Specify the field of view angle.
   ///   * nearValue: Specify the distances to the nearer depth clipping plane. This value must be positive.
   ///   * farValue: Specify the distances to the farther depth clipping plane. This value must be positive.
   ///   * width: Specify the width of the current viewport.
   ///   * height: Specify the height of the current viewport.
   static func perspective (fieldOfView : Float, nearValue : Float, farValue : Float, width : Float, height : Float) -> Matrix4f
   {
      let ratio = tan (fieldOfView / 2) * nearValue
   
      if (width > height)
      {
         let aspect = width * ratio / height
         
         return frustum (left: -aspect, right: aspect, bottom: -ratio, top: ratio, nearValue: nearValue, farValue: farValue)
      }
      else
      {
         let aspect = height * ratio / width
         
         return frustum (left: -ratio, right: ratio, bottom: -aspect, top: aspect, nearValue: nearValue, farValue: farValue)
      }
   }
   
   /// Creates an perspective projection matrix.
   /// * parameters:
   ///   * left: Specify the coordinates for the left vertical clipping plane.
   ///   * right: Specify the coordinates for the left vertical clipping plane.
   ///   * bottom : Specify the coordinates for the bottom horizontal clipping plane.
   ///   * top: Specify the coordinates for the bottom horizontal clipping plane.
   ///   * nearValue: Specify the distances to the nearer depth clipping plane. This value must be positive.
   ///   * farValue: Specify the distances to the farther depth clipping plane. This value must be positive.
   static func frustum (left : Float, right : Float, bottom : Float, top : Float, nearValue : Float, farValue : Float) -> Matrix4f
   {
      let r_l = right - left
      let t_b = top - bottom
      let f_n = farValue - nearValue
      let n_2 = 2 * nearValue
   
      let A = (right + left) / r_l
      let B = (top + bottom) / t_b
      let C = -farValue / f_n
      let D = -(nearValue * farValue) / f_n
      let E = n_2 / r_l
      let F = n_2 / t_b
   
      return Matrix4f (columns: (
         Vector4f (E, 0, 0,  0),
         Vector4f (0, F, 0,  0),
         Vector4f (A, B, C, -1),
         Vector4f (0, 0, D,  0)
      ))
   }
}
