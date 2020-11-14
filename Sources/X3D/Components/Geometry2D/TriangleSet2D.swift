//
//  TriangleSet2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TriangleSet2D :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TriangleSet2D" }
   internal final override class var component      : String { "Geometry2D" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "geometry" }

   // Fields

   @MFVec2f public final var vertices : [Vector2f]
   @SFBool  public final var solid    : Bool = false

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TriangleSet2D)

      addField (.inputOutput,    "metadata", $metadata)
      addField (.inputOutput,    "vertices", $vertices)
      addField (.initializeOnly, "solid",    $solid)

      $vertices .unit = .length
      
      geometryType = 2
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TriangleSet2D
   {
      return TriangleSet2D (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      rebuild ()
   }
   
   // Build
   
   internal final override func build ()
   {
      isSolid     = solid
      hasTexCoord = false

      for vertex in vertices
      {
         addPrimitive (point: Vector3f (vertex, 0))
      }
   }
   
   internal final override func generateTexCoords (_ primitives : inout Primitives)
   {
      let p = texCoordParams

      for i in 0 ..< primitives .count
      {
         let point = primitives [i] .point
         
         let t = Vector4f ((point [0] - p .min [0]) / p .Ssize,
                           (point [1] - p .min [1]) / p .Ssize,
                           0,
                           1)
         
         primitives [i] .texCoords = (t, t)
      }
   }
}
