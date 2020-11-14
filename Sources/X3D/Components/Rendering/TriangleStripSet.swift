//
//  TriangleStripSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TriangleStripSet :
   X3DComposedGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TriangleStripSet" }
   internal final override class var component      : String { "Rendering" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "geometry" }

   // Fields

   @MFInt32 public final var stripCount : [Int32]

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TriangleStripSet)

      addField (.inputOutput,    "metadata",        $metadata)
      addField (.initializeOnly, "solid",           $solid)
      addField (.initializeOnly, "ccw",             $ccw)
      addField (.initializeOnly, "colorPerVertex",  $colorPerVertex)
      addField (.initializeOnly, "normalPerVertex", $normalPerVertex)
      addField (.inputOutput,    "stripCount",      $stripCount)
      addField (.inputOutput,    "attrib",          $attrib)
      addField (.inputOutput,    "fogCoord",        $fogCoord)
      addField (.inputOutput,    "color",           $color)
      addField (.inputOutput,    "texCoord",        $texCoord)
      addField (.inputOutput,    "normal",          $normal)
      addField (.inputOutput,    "coord",           $coord)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TriangleStripSet
   {
      return TriangleStripSet (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $stripCount .addInterest (TriangleStripSet .set_stripCount, self)
      
      set_stripCount ()
      
      rebuild ()
   }
   
   // Event handlers
   
   private final var triangleIndex = [Int] ()
   
   private final func set_stripCount ()
   {
      // Build coordIndex
   
      triangleIndex .removeAll (keepingCapacity: true)
      
      var index = 0

      for s in 0 ..< stripCount .count
      {
         let vertexCount = Int (stripCount [s])

         for i in 0 ..< vertexCount - 2
         {
            let isOdd = i & 1 == 1
            
            triangleIndex .append (index + (isOdd ? i + 1 : i))
            triangleIndex .append (index + (isOdd ? i : i + 1))
            triangleIndex .append (index + (i + 2))
         }
   
         index += vertexCount
      }
   }
   
   // Build
   
   internal final override func getPolygonIndex (at index : Int) -> Int
   {
      return triangleIndex [index]
   }
   
   internal final override func build ()
   {
      build (verticesPerPolygon: 3,
             polygonsSize: triangleIndex .count,
             verticesPerFace: 3,
             trianglesSize: triangleIndex .count)
   }
}
