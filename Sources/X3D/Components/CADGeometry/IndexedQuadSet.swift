//
//  IndexedQuadSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class IndexedQuadSet :
   X3DComposedGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "IndexedQuadSet" }
   internal final override class var component      : String { "CADGeometry" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "geometry" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFInt32 public final var set_index : [Int32]
   @MFInt32 public final var index     : [Int32]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.IndexedQuadSet)

      addField (.inputOutput,    "metadata",        $metadata)
      addField (.inputOnly,      "set_index",       $set_index)
      addField (.initializeOnly, "solid",           $solid)
      addField (.initializeOnly, "ccw",             $ccw)
      addField (.initializeOnly, "colorPerVertex",  $colorPerVertex)
      addField (.initializeOnly, "normalPerVertex", $normalPerVertex)
      addField (.initializeOnly, "index",           $index)
      addField (.inputOutput,    "attrib",          $attrib)
      addField (.inputOutput,    "fogCoord",        $fogCoord)
      addField (.inputOutput,    "color",           $color)
      addField (.inputOutput,    "texCoord",        $texCoord)
      addField (.inputOutput,    "normal",          $normal)
      addField (.inputOutput,    "coord",           $coord)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> IndexedQuadSet
   {
      return IndexedQuadSet (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $set_index .addFieldInterest (to: $index)
      
      rebuild ()
   }

   // Build
   
   private static let indexMap : [Int] = [0, 1, 2,   0, 2, 3]
   
   internal final override func getTriangleIndex (at index : Int) -> Int
   {
      return index / 6 * 4 + IndexedQuadSet .indexMap [index % 6]
   }
   
   internal final override func getPolygonIndex (at index : Int) -> Int
   {
      return Int (self .index [index])
   }
   
   internal final override func build ()
   {
      var count = index .count

      count -= count % 4

      build (verticesPerPolygon: 4,
             polygonsSize: count,
             verticesPerFace: 6,
             trianglesSize: count / 4 * 6)
   }
}
