//
//  X3DViewVolume.swift
//  X3D
//
//  Created by Holger Seelig on 06.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ViewVolume
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
   
   public static func unProjectRay (_ winx : Float, _ winy : Float,
                                    _ modelViewMatrix : Matrix4f,
                                    _ projectionMatrix : Matrix4f,
                                    _ viewport : Vector4i) -> Line3f
   {
      let im = inverse (projectionMatrix * modelViewMatrix)
      let p1 = unProjectPoint (winx, winy, 0, im, viewport)
      let p2 = unProjectPoint (winx, winy, 1, im, viewport)
      
      return Line3f (point1: p1, point2: p2)
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
   
   public static func projectLine (_ line : Line3f, _ modelViewMatrix : Matrix4f, _ projectionMatrix : Matrix4f, _ viewport : Vector4i) -> Line3f
   {
      let modelViewProjectionMatrix = projectionMatrix * modelViewMatrix

      let point1 = projectPoint (line .point,                         modelViewProjectionMatrix, viewport)
      let point2 = projectPoint (line .point + line .direction * 1e9, modelViewProjectionMatrix, viewport)

      return Line3f (point1: point1, point2: point2)
   }
   
   public static func intersects (with box : Box3f, _ projectionMatrix : Matrix4f, _ viewport : Vector4i) -> Bool
   {
      let points1 = box .points
      let points2 = points (projectionMatrix, viewport)
      
      // Test the three planes spanned by the normal vectors of the faces of the box.

      let normals1 = box .normals

      if Sat .separated (normals1, points1, points2)
      {
         return false
      }
      
      // Test the six planes spanned by the normal vectors of the faces of the view volume.

      let normals2 = normals (points2)
      
      if Sat .separated (normals2, points1, points2)
      {
         return false
      }

      // Test the planes spanned by the edges of each object.

      var axes = [Vector3f] ()

      for axis1 in box .axes
      {
         for axis2 in edges (points2)
         {
            axes .append (cross (axis1, axis2))
         }
      }

      if Sat .separated (axes, points1, points2)
      {
         return false
      }

      // Both boxes intersect.

      return true
   }
   
   private static func points (_ projectionMatrix : Matrix4f, _ viewport : Vector4i) -> [Vector3f]
   {
      var points = [Vector3f] ()
      
      let x1     = Float (viewport [0])
      let x2     = Float (viewport [0] + viewport [2])
      let y1     = Float (viewport [1])
      let y2     = Float (viewport [1] + viewport [3])
      let matrix = projectionMatrix .inverse

      points .append (unProjectPoint (x1, y1, 0, matrix, viewport))
      points .append (unProjectPoint (x2, y1, 0, matrix, viewport))
      points .append (unProjectPoint (x2, y2, 0, matrix, viewport))
      points .append (unProjectPoint (x1, y2, 0, matrix, viewport))
      points .append (unProjectPoint (x1, y1, 1, matrix, viewport))
      points .append (unProjectPoint (x2, y1, 1, matrix, viewport))
      points .append (unProjectPoint (x2, y2, 1, matrix, viewport))
      points .append (unProjectPoint (x1, y2, 1, matrix, viewport))

      return points
   }
   
   // Return normals for SAT theorem.
   private static func normals (_ points : [Vector3f]) -> [Vector3f]
   {
      var normals = [Vector3f] ()
      
      normals .append (normal (points [0], points [1], points [2]))  // front
      normals .append (normal (points [7], points [4], points [0]))  // left
      normals .append (normal (points [6], points [2], points [1]))  // right
      normals .append (normal (points [2], points [6], points [7]))  // top
      normals .append (normal (points [1], points [0], points [4]))  // bottom
      normals .append (normal (points [4], points [7], points [6]))  // back

      return normals
   }
   
   // Return edges for SAT theorem.
   private static func edges (_ points : [Vector3f]) -> [Vector3f]
   {
      var edges = [Vector3f] ()
      
      edges .append (points [0] - points [1])
      edges .append (points [1] - points [2])
      edges .append (points [2] - points [3])
      edges .append (points [3] - points [0])

      edges .append (points [0] - points [4])
      edges .append (points [1] - points [5])
      edges .append (points [2] - points [6])
      edges .append (points [3] - points [7])

      return edges
   }
}
