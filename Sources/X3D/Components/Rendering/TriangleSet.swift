//
//  TriangleSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TriangleSet :
   X3DComposedGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "TriangleSet" }
   public final override class var component      : String { "Rendering" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "geometry" }

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TriangleSet)

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

   internal final override func create (with executionContext : X3DExecutionContext) -> TriangleSet
   {
      return TriangleSet (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      rebuild ()
   }

   // Build
   
   internal final override func build ()
   {
      guard let coordNode = coordNode else { return }
      
      build (verticesPerPolygon: 3,
             polygonsSize: coordNode .count,
             verticesPerFace: 3,
             trianglesSize: coordNode .count)
   }
   
   internal final override func makeNormals (_ verticesPerPolygon : Int, _ polygonsSize : Int) -> Normals
   {
      return makeFaceNormals (verticesPerPolygon, polygonsSize)
   }
}
