//
//  X3DViewVolume.swift
//  X3D
//
//  Created by Holger Seelig on 06.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import simd

public class X3DViewVolume
{
   public static func unProjectPoint (_ winx : Float, _ winy : Float, _ winz : Float,
                                      _ modelViewMatrix : Matrix4f,
                                      _ projectionMatrix : Matrix4f,
                                      _ viewport : Vector4i) -> Vector3f
   {
      return unProjectPoint (winx, winy, winz, inverse (projectionMatrix * modelViewMatrix), viewport)
   }

   public static func unProjectPoint (_ winx : Float, _ winy : Float, _ winz : Float, _ invModelViewProjectionMatrix : Matrix4f, _ viewport : Vector4i) -> Vector3f
   {
      // Transformation of normalized coordinates between -1 and 1
      var vin = Vector4f ((winx - Float (viewport [0])) / Float (viewport [2]) * 2 - 1,
                          (winy - Float (viewport [1])) / Float (viewport [3]) * 2 - 1,
                           winz,
                           1)

      //Objects coordinates
      vin = invModelViewProjectionMatrix * vin
      
      let d = 1 / vin .w

      return Vector3f (vin .x * d, vin .y * d, vin .z * d)
   }
   
   public static func projectPoint (_ point : Vector3f, _ modelViewMatrix : Matrix4f, _ projectionMatrix : Matrix4f, _ viewport : Vector4i) -> Vector3f
   {
      return projectPoint (point, projectionMatrix * modelViewMatrix, viewport)
   }

   public static func projectPoint (_ point : Vector3f, _ modelViewProjectionMatrix : Matrix4f, _ viewport : Vector4i) -> Vector3f
   {
      var vin = Vector4f (point, 1)

      vin = modelViewProjectionMatrix * vin

      let d = 1 / vin .w

      return Vector3f ((1 + vin .x * d) / 2 * Float (viewport [2]) + Float (viewport [0]),
                       (1 + vin .y * d) / 2 * Float (viewport [3]) + Float (viewport [1]),
                       (vin .z * d))
   }
}
