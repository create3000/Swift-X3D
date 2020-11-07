//
//  Rectangle2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Rectangle2D :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Rectangle2D" }
   internal final override class var component      : String { "Geometry2D" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "geometry" }

   // Fields

   @SFVec2f public final var size  : Vector2f = Vector2f (2, 2)
   @SFBool  public final var solid : Bool = false

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Rectangle2D)

      addField (.inputOutput,    "metadata", $metadata)
      addField (.initializeOnly, "size",     $size)
      addField (.initializeOnly, "solid",    $solid)

      $size .unit = .length
      
      geometryType = 2
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Rectangle2D
   {
      return Rectangle2D (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      rebuild ()
   }
   // Build
   
   internal final override func makeBBox () -> Box3f
   {
      return Box3f (min: Vector3f (-size / 2, 0),
                    max: Vector3f ( size / 2, 0))
   }

   internal final override func build ()
   {
      isSolid     = solid
      hasTexCoord = true
      
      // Size
      
      let x = size .x / 2
      let y = size .y / 2

      // Front Face
      
      addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], point: Vector3f (-x, -y, 0))
      addPrimitive (texCoords: [Vector4f (1, 0, 0, 1)], point: Vector3f ( x, -y, 0))
      addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], point: Vector3f ( x,  y, 0))
      
      addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], point: Vector3f (-x, -y, 0))
      addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], point: Vector3f ( x,  y, 0))
      addPrimitive (texCoords: [Vector4f (0, 1, 0, 1)], point: Vector3f (-x,  y, 0))
   }
}
