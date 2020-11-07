//
//  IndexedTriangleSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class IndexedTriangleSet :
   X3DComposedGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "IndexedTriangleSet" }
   internal final override class var component      : String { "Rendering" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "geometry" }

   // Fields

   @MFInt32 public final var set_index : MFInt32 .Value
   @MFInt32 public final var index     : MFInt32 .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.IndexedTriangleSet)

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

   internal final override func create (with executionContext : X3DExecutionContext) -> IndexedTriangleSet
   {
      return IndexedTriangleSet (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $set_index .addFieldInterest (to: $index)
      
      rebuild ()
   }

   // Build
   
   internal final override func getPolygonIndex (at index : Int) -> Int
   {
      return Int (self .index [index])
   }

   internal final override func build ()
   {
      build (verticesPerPolygon: 3,
             polygonsSize: index .count,
             verticesPerFace: 3,
             trianglesSize: index .count)
   }
}
