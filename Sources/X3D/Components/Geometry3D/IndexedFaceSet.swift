//
//  IndexedFaceSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import LibTessSwift
import simd

public final class IndexedFaceSet :
   X3DComposedGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "IndexedFaceSet" }
   public final override class var component      : String { "Geometry3D" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "geometry" }

   // Fields

   @MFInt32 public final var set_colorIndex    : MFInt32 .Value
   @MFInt32 public final var set_texCoordIndex : MFInt32 .Value
   @MFInt32 public final var set_normalIndex   : MFInt32 .Value
   @MFInt32 public final var set_coordIndex    : MFInt32 .Value
   @SFBool  public final var convex            : Bool = true
   @SFFloat public final var creaseAngle       : Float = 0
   @MFInt32 public final var colorIndex        : MFInt32 .Value
   @MFInt32 public final var texCoordIndex     : MFInt32 .Value
   @MFInt32 public final var normalIndex       : MFInt32 .Value
   @MFInt32 public final var coordIndex        : MFInt32 .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.IndexedFaceSet)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.inputOnly,      "set_colorIndex",    $set_colorIndex)
      addField (.inputOnly,      "set_texCoordIndex", $set_texCoordIndex)
      addField (.inputOnly,      "set_normalIndex",   $set_normalIndex)
      addField (.inputOnly,      "set_coordIndex",    $set_coordIndex)
      addField (.initializeOnly, "solid",             $solid)
      addField (.initializeOnly, "ccw",               $ccw)
      addField (.initializeOnly, "convex",            $convex)
      addField (.initializeOnly, "creaseAngle",       $creaseAngle)
      addField (.initializeOnly, "colorPerVertex",    $colorPerVertex)
      addField (.initializeOnly, "normalPerVertex",   $normalPerVertex)
      addField (.initializeOnly, "colorIndex",        $colorIndex)
      addField (.initializeOnly, "texCoordIndex",     $texCoordIndex)
      addField (.initializeOnly, "normalIndex",       $normalIndex)
      addField (.initializeOnly, "coordIndex",        $coordIndex)
      addField (.inputOutput,    "attrib",            $attrib)
      addField (.inputOutput,    "fogCoord",          $fogCoord)
      addField (.inputOutput,    "color",             $color)
      addField (.inputOutput,    "texCoord",          $texCoord)
      addField (.inputOutput,    "normal",            $normal)
      addField (.inputOutput,    "coord",             $coord)

      $creaseAngle .unit = .angle
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> IndexedFaceSet
   {
      return IndexedFaceSet (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()

      $set_colorIndex    .addFieldInterest (to: $colorIndex)
      $set_texCoordIndex .addFieldInterest (to: $texCoordIndex)
      $set_normalIndex   .addFieldInterest (to: $normalIndex)
      $set_coordIndex    .addFieldInterest (to: $coordIndex)
      
      rebuild ()
   }

   // Build
   
   private typealias Vertices = ContiguousArray <Int>
   private typealias Polygon  = (face: Int, vertices: Vertices, triangles: Vertices)
   private typealias Polygons = ContiguousArray <Polygon>
   
   private final func getColorIndex (i : Int) -> Int
   {
      return Int (colorIndex .indices .contains (i) ? colorIndex [i] : coordIndex [i])
   }

   private final func getColorIndex (face : Int) -> Int
   {
      return colorIndex .indices .contains (face) ? Int (colorIndex [face]) : face
   }
   
   private final func getTexCoordIndex (i : Int) -> Int
   {
      return Int (texCoordIndex .indices .contains (i) ? texCoordIndex [i] : coordIndex [i])
   }

   private final func getNormalIndex (i : Int) -> Int
   {
      return Int (normalIndex .indices .contains (i) ? normalIndex [i] : coordIndex [i])
   }

   private final func getNormalIndex (face : Int) -> Int
   {
      return normalIndex .indices .contains (face) ? Int (normalIndex [face]) : face
   }

   internal final override func build ()
   {
      guard let coordNode = coordNode else { return }
      guard !coordIndex .isEmpty      else { return }

      isSolid            = solid
      isCounterClockwise = ccw
      hasFogCoord        = fogCoordNode != nil
      hasColor           = colorNode != nil
      hasTexCoord        = texCoordNode != nil
      
      let polygons  = tessellate ()
      var fogDepth  = Float (0)
      var color     = Color4f .one
      var texCoords = [Vector4f] ()
      let normals   = normalNode == nil ? makeNormals (for: polygons, with: coordNode) : Normals ()
      var normal    = Vector3f .zero

      for (face, _, triangles) in polygons
      {
         for i in triangles
         {
            let index = Int (coordIndex [i])
            
            if let fogCoordNode = fogCoordNode
            {
               fogDepth = fogCoordNode .get1Depth (at: index)
            }
            
            if let colorNode = colorNode
            {
               if colorPerVertex
               {
                  color = colorNode .get1Color (at: getColorIndex (i: i))
               }
               else
               {
                  color = colorNode .get1Color (at: getColorIndex (face: face))
               }
            }
            
            if let texCoordNode = texCoordNode
            {
               texCoords .removeAll (keepingCapacity: true)
               
               texCoordNode .get1Point (at: getTexCoordIndex (i: i), array: &texCoords)
            }
            
            if let normalNode = normalNode
            {
               if normalPerVertex
               {
                  normal = normalNode .get1Vector (at: getNormalIndex (i: i))
               }
               else
               {
                  normal = normalNode .get1Vector (at: getNormalIndex (face: face))
               }
            }
            else
            {
               normal = normals [i]
            }

            let point = coordNode .get1Point (at: index)

            addPrimitive (fogDepth: fogDepth,
                          color: color,
                          texCoords: texCoords,
                          normal: normal,
                          point: point)
         }
      }
   }
   
   private final func tessellate () -> Polygons
   {
      // Add -1 (polygon end marker) to coordIndex if not present.
      
      if coordIndex .last! > -1
      {
         coordIndex .append (-1)
      }
      
      // Construct triangle array and determine the number of used points.
      
      var polygons = Polygons ()
      var vertices = Vertices ()
      var face     = 0

      for i in 0 ..< coordIndex .count
      {
         if coordIndex [i] > -1
         {
            // Add vertex index.
            vertices .append (i)
         }
         else
         {
            // Negativ index.
            
            switch vertices .count
            {
               case 0, 1, 2: do
               {
                  // Remove degenerated face.
               }
               case 3: do
               {
                  // Add polygon with one triangle.
                 
                  polygons .append ((face, vertices, vertices))
               }
               default: do
               {
                  // Tessellate polygons.

                  if convex
                  {
                     polygons .append ((face, vertices, tessellate (convex: vertices)))
                  }
                  else
                  {
                     polygons .append ((face, vertices, tessellate (concave: vertices)))
                  }
               }
            }
            
            vertices .removeAll (keepingCapacity: true)

            face += 1
        }
      }
      
      return polygons
   }
   
   private final func tessellate (convex polygon : Vertices) -> Vertices
   {
      var triangles = Vertices ()

      for i in 1 ..< polygon .count - 1
      {
         triangles .append (polygon [0])
         triangles .append (polygon [i])
         triangles .append (polygon [i + 1])
      }
      
      return triangles
   }
   
   private final func tessellate (concave polygon : Vertices) -> Vertices
   {
      do
      {
         guard let tess = TessC () else { return [ ] }
         
         // Map from Vector3f to CVector3 (LibTessSwift's vector representation).
         var map     = [Vector3f : Int] ()
         var contour = [Vector3f] ()

         for i in polygon
         {
            let point = coordNode! .get1Point (at: Int (coordIndex [i]))
            
            map [point] = i
            
            contour .append (point)
         }
         
         // Add the contour to LibTess.
         tess .addContour (contour)

         // Tesselate - if no errors are thrown, we're good!
         let (points, indices) = try tess .tessellate (windingRule: .evenOdd, elementType: .polygons, polySize: 3)

         // Extract each index for each polygon triangle found.
         var triangles = Vertices ()

         for i in indices
         {
            let point = points [i]
            let index = map [point] ?? map [contour .min (by: { distance (point, $0) < distance (point, $1) })!]!
            
            triangles .append (index)
         }
         
         return triangles
      }
      catch
      {
         return [ ]
      }
   }
   
   private final func makeNormals (for polygons : Polygons, with coordNode : X3DCoordinateNode) -> Normals
   {
      var normalIndex = NormalIndex ()
      var faceNormals = Normals (repeating: .zero, count: coordIndex .count)
      var normal      = Vector3f .zero

      for (_, vertices, _) in polygons
      {
         switch vertices .count
         {
            case 0, 1, 2: do
            {
               continue
            }
            case 3: do
            {
               normal = coordNode .makeNormal (index1: Int (coordIndex [vertices [0]]),
                                               index2: Int (coordIndex [vertices [1]]),
                                               index3: Int (coordIndex [vertices [2]]))
            }
            case 4: do
            {
               normal = coordNode .makeNormal (index1: Int (coordIndex [vertices [0]]),
                                               index2: Int (coordIndex [vertices [1]]),
                                               index3: Int (coordIndex [vertices [2]]),
                                               index4: Int (coordIndex [vertices [3]]))
            }
            default: do
            {
               normal = makePolygonNormal (for: vertices)
            }
         }

         for i in vertices
         {
            // Add a normal index for each point.
            normalIndex [Int (coordIndex [i]), default: [ ]] .append (i)
            
            // Add this normal for each vertex.
            faceNormals [i] = normal
         }
      }
      
      if !ccw
      {
         for i in 0 ..< faceNormals .count
         {
            faceNormals [i] = -faceNormals [i]
         }
      }

      return generateNormals (normalIndex: normalIndex, faceNormals: faceNormals, creaseAngle: creaseAngle)
   }
   
   private final func makePolygonNormal (for vertices : Vertices) -> Vector3f
   {
      guard let coordNode = coordNode else { return .zero }
      
      // Determine polygon normal.
      // We use Newell's method https://www.opengl.org/wiki/Calculating_a_Surface_Normal here:

      var normal  = Vector3f .zero
      var current = Vector3f .zero
      var next    = coordNode .get1Point (at: Int (coordIndex [vertices [0]]))

      for i in 0 ..< vertices .count
      {
         swap (&current, &next)

         next = coordNode .get1Point (at: Int (coordIndex [vertices [(i + 1) % vertices .count]]))

         normal .x += (current .y - next .y) * (current .z + next .z)
         normal .y += (current .z - next .z) * (current .x + next .x)
         normal .z += (current .x - next .x) * (current .y + next .y)
      }

      return normalize (normal)
   }
}
