//
//  QuadSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class QuadSet :
   X3DComposedGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "QuadSet" }
   internal final override class var component      : String { "CADGeometry" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "geometry" }

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.QuadSet)

      addField (.inputOutput,    "metadata",        $metadata)
      addField (.initializeOnly, "solid",           $solid)
      addField (.initializeOnly, "ccw",             $ccw)
      addField (.initializeOnly, "colorPerVertex",  $colorPerVertex)
      addField (.initializeOnly, "normalPerVertex", $normalPerVertex)
      addField (.inputOutput,    "attrib",          $attrib)
      addField (.inputOutput,    "fogCoord",        $fogCoord)
      addField (.inputOutput,    "color",           $color)
      addField (.inputOutput,    "texCoord",        $texCoord)
      addField (.inputOutput,    "normal",          $normal)
      addField (.inputOutput,    "coord",           $coord)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> QuadSet
   {
      return QuadSet (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      rebuild ()
   }

   // Build
   
   private static let indexMap : [Int] = [0, 1, 2,   0, 2, 3]
   
   internal final override func getTriangleIndex (at index : Int) -> Int
   {
      let mod = index % 6

      return (index - mod) / 6 * 4 + QuadSet .indexMap [mod]
   }
   
   internal final override func build ()
   {
      guard let coordNode = coordNode else { return }

      var count = coordNode .count

      count -= count % 4

      build (verticesPerPolygon: 4,
             polygonsSize: count,
             verticesPerFace: 6,
             trianglesSize: count / 4 * 6)
   }
   
   internal final override func makeNormals (_ verticesPerPolygon : Int, _ polygonsSize : Int) -> Normals
   {
      return makeFaceNormals (verticesPerPolygon, polygonsSize)
   }
}
