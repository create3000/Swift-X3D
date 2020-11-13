//
//  File.swift
//  
//
//  Created by Holger Seelig on 13.11.20.
//

// Class to represent the Separating Axis Theorem.
public final class Sat
{
   /// Returns true if the object defined by @a points1 and the object defined by @a points2 are separated, otherwise
   /// false.  You must provide suitable axes for this test to operate on.  This test only gives reasonable result for
   /// convex objects.  For 2d objects it is sufficient to use the normal vectors of the edges as axes.  For 3d
   /// objects, the axes are the normal vectors of the faces of each object and the cross product of each edge from one
   /// object with each edge from the other object.  It is not needed to provide normalized axes.
   public static func separated (_ axes : [Vector3f], _ points1 : [Vector3f], _ points2 : [Vector3f]) -> Bool
   {
      // http://gamedev.stackexchange.com/questions/25397/obb-vs-obb-collision-detection

      for axis in axes
      {
         let p1 = project (points1, axis)
         let p2 = project (points2, axis)

         if overlaps (p1 .min, p1 .max, p2 .min, p2 .max)
         {
            continue
         }

         return true
      }

      return false
   }
   
   ///  Projects points to axis and returns the minimum and maximum bounds.
   private static func project (_ points : [Vector3f], _ axis : Vector3f) -> (min : Float, max : Float)
   {
      var min : Float = .infinity
      var max : Float = -.infinity

      for point in points
      {
         // Just dot it to get the min and max along this axis.
         // NOTE: the axis must be normalized to get accurate projections to calculate the MTV, but if it is only needed to
         // know whether it overlaps, every axis can be used.

         let dotVal = dot (point, axis)

         min = Swift .min (min, dotVal)
         max = Swift .max (max, dotVal)
      }
      
      return (min, max)
   }

   ///  Returns true if both ranges overlap, otherwise false.
   private static func overlaps (_ min1 : Float, _ max1 : Float, _ min2 : Float, _ max2 : Float) -> Bool
   {
      return isBetween (min2, min1, max1) || isBetween (min1, min2, max2)
   }

   ///  Returns true if @a value is between @a lowerBound and @a upperBound, otherwise false.
   private static func isBetween (_ value : Float, _ lowerBound : Float, _ upperBound : Float) -> Bool
   {
      return lowerBound <= value && value <= upperBound
   }
}
