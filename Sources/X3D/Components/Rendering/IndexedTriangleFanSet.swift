//
//  IndexedTriangleFanSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class IndexedTriangleFanSet :
   X3DComposedGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "IndexedTriangleFanSet" }
   internal final override class var component      : String { "Rendering" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "geometry" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFInt32 public final var set_index : [Int32]
   @MFInt32 public final var index     : [Int32]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.IndexedTriangleFanSet)

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

   internal final override func create (with executionContext : X3DExecutionContext) -> IndexedTriangleFanSet
   {
      return IndexedTriangleFanSet (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $set_index .addFieldInterest (to: $index)
      
      $index .addInterest ("set_index_", { $0 .set_index_ () }, self)
      
      set_index_ ()
      
      rebuild ()
   }
   
   // Event handlers
   
   private final var triangleIndex = [Int] ()
   
   private final func set_index_ ()
   {
      // Build coordIndex

      triangleIndex .removeAll (keepingCapacity: true)
      
      var i = 0

      while i < index .count
      {
         let first = Int (index [i])
         
         if first >= 0
         {
            i += 1
            
            if i < index .count
            {
               var second = Int (index [i])

               if second >= 0
               {
                  i += 1

                  while i < index .count
                  {
                     let third = Int (index [i])

                     if third < 0
                     {
                        break
                     }

                     triangleIndex .append (first)
                     triangleIndex .append (second)
                     triangleIndex .append (third)

                     second = third
                     
                     i += 1
                  }
               }
            }
         }
         
         i += 1
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
