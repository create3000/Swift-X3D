//
//  TriangleFanSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TriangleFanSet :
   X3DComposedGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TriangleFanSet" }
   internal final override class var component      : String { "Rendering" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "geometry" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFInt32 public final var fanCount : [Int32]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TriangleFanSet)

      addField (.inputOutput,    "metadata",        $metadata)
      addField (.initializeOnly, "solid",           $solid)
      addField (.initializeOnly, "ccw",             $ccw)
      addField (.initializeOnly, "colorPerVertex",  $colorPerVertex)
      addField (.initializeOnly, "normalPerVertex", $normalPerVertex)
      addField (.inputOutput,    "fanCount",        $fanCount)
      addField (.inputOutput,    "attrib",          $attrib)
      addField (.inputOutput,    "fogCoord",        $fogCoord)
      addField (.inputOutput,    "color",           $color)
      addField (.inputOutput,    "texCoord",        $texCoord)
      addField (.inputOutput,    "normal",          $normal)
      addField (.inputOutput,    "coord",           $coord)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TriangleFanSet
   {
      return TriangleFanSet (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $fanCount .addInterest ("set_fanCount", { $0 .set_fanCount () }, self)
      
      set_fanCount ()
      
      rebuild ()
   }
   
   // Event handlers
   
   private final var triangleIndex = [Int] ()
   
   private final func set_fanCount ()
   {
      // Build coordIndex
   
      triangleIndex .removeAll (keepingCapacity: true)
      
      var index = 0

      for f in 0 ..< fanCount .count
      {
         let vertexCount = Int (fanCount [f])

         for i in 1 ..< vertexCount - 1
         {
            triangleIndex .append (index)
            triangleIndex .append (index + i)
            triangleIndex .append (index + i + 1)
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
