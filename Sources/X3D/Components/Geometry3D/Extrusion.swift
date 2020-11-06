//
//  Extrusion.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import LibTessSwift
import simd

public final class Extrusion :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Extrusion" }
   public final override class var component      : String { "Geometry3D" }
   public final override class var componentLevel : Int32 { 4 }
   public final override class var containerField : String { "geometry" }

   // Fields

   @MFVec2f    public final var set_crossSection : MFVec2f .Value
   @MFRotation public final var set_orientation  : MFRotation .Value
   @MFVec2f    public final var set_scale        : MFVec2f .Value
   @MFVec3f    public final var set_spine        : MFVec3f .Value
   @SFBool     public final var beginCap         : Bool = true
   @SFBool     public final var endCap           : Bool = true
   @SFBool     public final var solid            : Bool = true
   @SFBool     public final var ccw              : Bool = true
   @SFBool     public final var convex           : Bool = true
   @SFFloat    public final var creaseAngle      : Float = 0
   @MFVec2f    public final var crossSection     : MFVec2f .Value = [Vector2f (1, 1), Vector2f (1, -1), Vector2f (-1, -1), Vector2f (-1, 1), Vector2f (1, 1)]
   @MFRotation public final var orientation      : MFRotation .Value = [.identity]
   @MFVec2f    public final var scale            : MFVec2f .Value = [Vector2f (1, 1)]
   @MFVec3f    public final var spine            : MFVec3f .Value = [Vector3f (0, 0, 0), Vector3f (0, 1, 0)]

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Extrusion)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOnly,      "set_crossSection", $set_crossSection)
      addField (.inputOnly,      "set_orientation",  $set_orientation)
      addField (.inputOnly,      "set_scale",        $set_scale)
      addField (.inputOnly,      "set_spine",        $set_spine)
      addField (.initializeOnly, "beginCap",         $beginCap)
      addField (.initializeOnly, "endCap",           $endCap)
      addField (.initializeOnly, "solid",            $solid)
      addField (.initializeOnly, "ccw",              $ccw)
      addField (.initializeOnly, "convex",           $convex)
      addField (.initializeOnly, "creaseAngle",      $creaseAngle)
      addField (.initializeOnly, "crossSection",     $crossSection)
      addField (.initializeOnly, "orientation",      $orientation)
      addField (.initializeOnly, "scale",            $scale)
      addField (.initializeOnly, "spine",            $spine)

      $creaseAngle  .unit = .angle
      $crossSection .unit = .length
      $spine        .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Extrusion
   {
      return Extrusion (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()

      $set_crossSection .addFieldInterest (to: $crossSection)
      $set_orientation  .addFieldInterest (to: $orientation)
      $set_scale        .addFieldInterest (to: $scale)
      $set_spine        .addFieldInterest (to: $spine)
      
      rebuild ()
   }
   
   // Build
   
   internal final override func build ()
   {
      guard spine .count > 1 && crossSection .count > 1 else { return }

      isSolid            = solid
      isCounterClockwise = ccw
      hasTexCoord        = true

      func INDEX (_ n : Int, _ k : Int) -> Int { n * crossSection .count + k }

      let numSpines          = spine .count
      let closedSpine        = self .closedSpine
      let closedCrossSection = self .closedCrossSection

      // For caps calculation

      var min = crossSection [0]
      var max = crossSection [0]

      for k in 1 ..< crossSection .count
      {
         min = simd_min (min, crossSection [k])
         max = simd_max (max, crossSection [k])
      }

      let capSize      = max - min
      let capMax       = Swift .max (capSize .x, capSize .y)
      let numCapPoints = closedCrossSection ? crossSection .count - 1 : crossSection .count

      // Create

      let points      = makePoints ()
      var coordIndex  = [Int] ()
      var normalIndex = NormalIndex()
      var normals     = Normals ()
      var texCoords   = [Vector4f] ()

      // Build body.

      let numCrossSection_1 = crossSection .count - 1
      let numCrossSection_2 = crossSection .count - 2
      let numSpine_1        = numSpines - 1
      let numSpine_2        = numSpines - 2

      // Remember the most left and most right points for better normal generation.

      var indexLeft  = INDEX (0, 0)
      var indexRight = INDEX (0, closedCrossSection ? 0 : numCrossSection_1)

      for n in 0 ..< numSpine_1
      {
         for k in 0 ..< numCrossSection_1
         {
            let n1 = closedSpine        && n == numSpine_2        ? 0 : n + 1
            let k1 = closedCrossSection && k == numCrossSection_2 ? 0 : k + 1

            // k      k+1
            //
            // p4 ----- p3   n+1
            //  |     / |
            //  |   /   |
            //  | /     |
            // p1 ----- p2   n

            var p1 = INDEX (n,  k)
            let p2 = INDEX (n,  k1)
            var p3 = INDEX (n1, k1)
            let p4 = INDEX (n1, k)

            let length1   = length (points [p2] - points [p3]) >= 1e-7
            let length2   = length (points [p4] - points [p1]) >= 1e-7
            let texCoord1 = Vector4f (Float (      k) / Float (numCrossSection_1), Float (      n) / Float (numSpine_1), 0, 1)
            let texCoord2 = Vector4f (Float ((k + 1)) / Float (numCrossSection_1), Float (      n) / Float (numSpine_1), 0, 1)
            let texCoord3 = Vector4f (Float ((k + 1)) / Float (numCrossSection_1), Float ((n + 1)) / Float (numSpine_1), 0, 1)
            let texCoord4 = Vector4f (Float (      k) / Float (numCrossSection_1), Float ((n + 1)) / Float (numSpine_1), 0, 1)
            let normal1   = normal (points [p1], points [p2], points [p3])
            let normal2   = normal (points [p1], points [p3], points [p4])

            // Merge points on the most left and most right side if spine is coincident for better normal generation.

            if k == 0
            {
               if length2
               {
                  indexLeft = p1
               }
               else
               {
                  p1 = indexLeft
               }
            }

            if k == numCrossSection_2
            {
               if length1
               {
                  indexRight = p2
               }
               else
               {
                  p3 = indexRight
               }
            }

            // If there are coincident spine points then one length can be zero.

            if length1
            {
               // p1
               if length2
               {
                  texCoords .append (texCoord1)
               }
               else
               {
                  // Cone case on the right side:
                  texCoords .append (Vector4f ((texCoord1 .x + texCoord4 .x) / 2,
                                               (texCoord1 .y + texCoord4 .y) / 2,
                                               0,
                                               1))
               }
               
               coordIndex .append (p1)
               normalIndex [p1, default: [ ]] .append (normals .count)
               normals .append (normal1)

               // p2
               texCoords .append (texCoord2)
               coordIndex .append (p2)
               normalIndex [p2, default: [ ]] .append (normals .count)
               normals .append (normal1)

               // p3
               texCoords .append (texCoord3)
               coordIndex .append (p3)
               normalIndex [p3, default: [ ]] .append (normals .count)
               normals .append (normal1)
            }

            if length2
            {
               // p1
               texCoords .append (texCoord1)
               coordIndex .append (p1)
               normalIndex [p1, default: [ ]] .append (normals .count)
               normals .append (normal2)

               // p3
               if length1
               {
                  texCoords .append (texCoord3)
               }
               else
               {
                  // Cone case on the left side:
                  texCoords .append (Vector4f ((texCoord3 .x + texCoord2 .x) / 2,
                                               (texCoord3 .y + texCoord2 .y) / 2,
                                               0,
                                               1))
               }

               coordIndex .append (p3)
               normalIndex [p3, default: [ ]] .append (normals .count)
               normals .append (normal2)

               // p4
               texCoords .append (texCoord4)
               coordIndex .append (p4)
               normalIndex [p4, default: [ ]] .append (normals .count)
               normals .append (normal2)
            }
         }
      }

      // Refine body normals and add them.
      
      if !ccw
      {
         for i in 0 ..< normals .count
         {
            normals [i] = -normals [i]
         }
      }

      normals = generateNormals (normalIndex: normalIndex, faceNormals: normals, creaseAngle: creaseAngle)
      
      // Add body primitives.
      
      for i in 0 ..< coordIndex .count
      {
         addPrimitive (texCoords: [texCoords [i]],
                       normal: normals [i],
                       point: points [coordIndex [i]])
      }
      
      // Build caps.

      if capMax != 0 && crossSection .count > 2
      {
         if beginCap
         {
            let j       = 0
            var polygon = Cap ()

            for k in 0 ..< numCapPoints
            {
               let index    = INDEX (j, numCapPoints - 1 - k)
               let point    = points [index]
               let texCoord = (crossSection [numCapPoints - 1 - k] - min) / capMax
                  
               polygon .append ((point, Vector4f (texCoord .x, texCoord .y, 0, 1)))
            }

            buildCap (polygon)
         }

         if endCap
         {
            let j       = numSpines - 1
            var polygon = Cap ()

            for k in 0 ..< numCapPoints
            {
               let index    = INDEX (j, k)
               let point    = points [index]
               let texCoord = (crossSection [k] - min) / capMax
                  
               polygon .append ((point, Vector4f (texCoord .x, texCoord .y, 0, 1)))
            }
            
            buildCap (polygon)
         }
      }
   }
   
   private final var closedCrossSection : Bool
   {
      crossSection .first! == crossSection .last!
   }

   private final var closedSpine : Bool
   {
      spine .first! == spine .last! && (orientation .isEmpty || orientation .first! == orientation .last!)
   }

   private final func makePoints () -> [Vector3f]
   {
      var points = [Vector3f] ()

      // Calculate SCP rotations.

      let rotations = makeRotations ()

      // Calculate vertices.

      for i in 0 ..< spine .count
      {
         var matrix = rotations [i]

         if !orientation .isEmpty
         {
            matrix *= Matrix4f (orientation [min (i, orientation .count - 1)])
         }

         if !scale .isEmpty
         {
            let s = scale [min (i, scale .count - 1)]
            var m = Matrix4f .identity
            
            m [0] [0] = s .x
            m [2] [2] = s .y

            matrix *= m
         }

         for vector in crossSection
         {
            points .append (matrix * Vector3f (vector .x, 0, vector .y))
         }
      }

      return points
   }
   
   private final func makeRotations () -> [Matrix4f]
   {
      var rotations = [Matrix4f] ()
      
      // calculate SCP rotations

      let numSpines   = spine .count
      let firstSpine  = spine .first!
      let closedSpine = self .closedSpine

      // SCP axes:
      var SCPxAxis = Vector3f .zero
      var SCPyAxis = Vector3f .zero
      var SCPzAxis = Vector3f .zero

      // SCP for the first point:
      if closedSpine
      {
         // Find first defined Y-axis.
         for i in 1 ..< numSpines - 2
         {
            SCPyAxis = normalize (spine [i] - spine [numSpines - 2])

            if SCPyAxis != .zero
            {
               break
            }
         }

         // Find first defined Z-axis.
         for i in 0 ..< numSpines - 2
         {
            SCPzAxis = normalize (cross (spine [i + 1] - spine [i], spine [numSpines - 2] - spine [i]))

            if SCPzAxis != .zero
            {
               break
            }
         }
      }
      else
      {
         // Find first defined Y-axis.
         for i in 0 ..< numSpines - 1
         {
            SCPyAxis = normalize (spine [i + 1] - spine [i])

            if SCPyAxis != .zero
            {
               break
            }
         }

         // Find first defined Z-axis.
         for i in 1 ..< numSpines - 1
         {
            SCPzAxis = normalize (cross (spine [i + 1] - spine [i], spine [i - 1] - spine [i]))

            if SCPzAxis != .zero
            {
               break
            }
         }
      }

      // The entire spine is coincident:
      if SCPyAxis == .zero
      {
         SCPyAxis = .yAxis
      }

      // The entire spine is collinear:
      if SCPzAxis == .zero
      {
         SCPzAxis = Rotation4f (from: .yAxis, to: SCPyAxis) * Vector3f .zAxis
      }

      // We do not have to normalize SCPxAxis, as SCPyAxis and SCPzAxis are orthogonal.
      SCPxAxis = cross (SCPyAxis, SCPzAxis)

      // Get first spine
      let s = firstSpine

      rotations .append (Matrix4f (columns: (Vector4f (SCPxAxis .x, SCPxAxis .y, SCPxAxis .z, 0),
                                             Vector4f (SCPyAxis .x, SCPyAxis .y, SCPyAxis .z, 0),
                                             Vector4f (SCPzAxis .x, SCPzAxis .y, SCPzAxis .z, 0),
                                             Vector4f (s .x,        s .y,        s .z,        1))))

      // For all points other than the first or last:

      var SCPyAxisPrevious = SCPyAxis
      var SCPzAxisPrevious = SCPzAxis

      for i in 1 ..< numSpines - 1
      {
         let s = spine [i]

         SCPyAxis = normalize (spine [i + 1] - spine [i - 1])
         SCPzAxis = normalize (cross (spine [i + 1] - s, spine [i - 1] - s))

         // g.
         if dot (SCPzAxisPrevious, SCPzAxis) < 0
         {
            SCPzAxis = -SCPzAxis
         }

         // The two points used in computing the Y-axis are coincident.
         if SCPyAxis == .zero
         {
            SCPyAxis = SCPyAxisPrevious
         }
         else
         {
            SCPyAxisPrevious = SCPyAxis
         }

         // The three points used in computing the Z-axis are collinear.
         if SCPzAxis == .zero
         {
            SCPzAxis = SCPzAxisPrevious
         }
         else
         {
            SCPzAxisPrevious = SCPzAxis
         }

         // We do not have to normalize SCPxAxis, as SCPyAxis and SCPzAxis are orthogonal.
         SCPxAxis = cross (SCPyAxis, SCPzAxis)
         
         rotations .append (Matrix4f (columns: (Vector4f (SCPxAxis .x, SCPxAxis .y, SCPxAxis .z, 0),
                                                Vector4f (SCPyAxis .x, SCPyAxis .y, SCPyAxis .z, 0),
                                                Vector4f (SCPzAxis .x, SCPzAxis .y, SCPzAxis .z, 0),
                                                Vector4f (s .x,        s .y,        s .z,        1))))
      }

      // SCP for the last point
      if closedSpine
      {
         // The SCP for the first and last points is the same.
         rotations .append (rotations .first!)
      }
      else
      {
         let s = spine [numSpines - 1]

         SCPyAxis = normalize (s - spine [numSpines - 2])

         if spine .count > 2
         {
            SCPzAxis = normalize (cross (s - spine [numSpines - 2], spine [numSpines - 3] - spine [numSpines - 2]))
         }

         // g.
         if dot (SCPzAxisPrevious, SCPzAxis) < 0
         {
            SCPzAxis = -SCPzAxis
         }

         // The two points used in computing the Y-axis are coincident.
         if SCPyAxis == .zero
         {
            SCPyAxis = SCPyAxisPrevious
         }
         else
         {
            SCPyAxisPrevious = SCPyAxis
         }

         // The three points used in computing the Z-axis are collinear.
         if SCPzAxis == .zero
         {
            SCPzAxis = SCPzAxisPrevious
         }

         // We do not have to normalize SCPxAxis, as SCPyAxis and SCPzAxis are orthogonal.
         SCPxAxis = cross (SCPyAxis, SCPzAxis)
         
         rotations .append (Matrix4f (columns: (Vector4f (SCPxAxis .x, SCPxAxis .y, SCPxAxis .z, 0),
                                                Vector4f (SCPyAxis .x, SCPyAxis .y, SCPyAxis .z, 0),
                                                Vector4f (SCPzAxis .x, SCPzAxis .y, SCPzAxis .z, 0),
                                                Vector4f (s .x,        s .y,        s .z,        1))))
      }

      return rotations
   }
   
   typealias Cap = [(point: Vector3f, texCoord: Vector4f)]
   
   private final func buildCap (_ polygon : Cap)
   {
      let triangles = convex ? tessellate (convex: polygon) : tessellate (concave: polygon)

      guard triangles .count >= 3 else { return }
   
      var normal = makePolygonNormal (for: polygon)
      
      if !ccw
      {
         normal = -normal
      }

      for vertex in triangles
      {
         addPrimitive (texCoords: [vertex .texCoord],
                       normal: normal,
                       point: vertex .point)
      }
   }

   private final func tessellate (convex polygon : Cap) -> Cap
   {
      var triangles = Cap ()

      for i in 1 ..< polygon .count - 1
      {
         triangles .append (polygon [0])
         triangles .append (polygon [i])
         triangles .append (polygon [i + 1])
      }
      
      return triangles
   }

   private final func tessellate (concave polygon : Cap) -> Cap
   {
      do
      {
         guard let tess = TessC () else { return [ ] }
         
         // Map from Vector3f to CVector3 (LibTessSwift's vector representation).
         var map     = [Vector3f : Int] ()
         var contour = [Vector3f] ()

         for i in 0 ..< polygon .count
         {
            let point = polygon [i] .point
            
            map [point] = i
            
            contour .append (point)
         }
         
         // Add the contour to LibTess.
         tess .addContour (contour)

         // Tesselate - if no errors are thrown, we're good!
         let (points, indices) = try tess .tessellate (windingRule: .evenOdd, elementType: .polygons, polySize: 3)

         // Extract each index for each polygon triangle found.
         var triangles = Cap ()

         for i in indices
         {
            let point = points [i]
            let index = map [point] ?? map [contour .min (by: { distance (point, $0) < distance (point, $1) })!]!
            
            triangles .append (polygon [index])
         }
         
         return triangles
      }
      catch
      {
         return [ ]
      }
   }
   
   private final func makePolygonNormal (for polygon : Cap) -> Vector3f
   {
      // Determine polygon normal.
      // We use Newell's method https://www.opengl.org/wiki/Calculating_a_Surface_Normal here:

      var normal  = Vector3f .zero
      var current = Vector3f .zero
      var next    = polygon [0] .point

      for i in 0 ..< polygon .count
      {
         swap (&current, &next)

         next = polygon [(i + 1) % polygon .count] .point

         normal .x += (current .y - next .y) * (current .z + next .z)
         normal .y += (current .z - next .z) * (current .x + next .x)
         normal .z += (current .x - next .x) * (current .y + next .y)
      }

      return normalize (normal)
   }
}
