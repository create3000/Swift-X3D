//
//  Box.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Box :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Box" }
   public final override class var component      : String { "Geometry3D" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "geometry" }

   // Fields

   @SFVec3f public final var size  : Vector3f = Vector3f (2, 2, 2)
   @SFBool  public final var solid : Bool = true

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Box)

      addField (.inputOutput,    "metadata", $metadata)
      addField (.initializeOnly, "size",     $size)
      addField (.initializeOnly, "solid",    $solid)

      $size .unit = .length
   }
   
   internal final override func create (with executionContext : X3DExecutionContext) -> Box
   {
      return Box (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      rebuild ()
   }
   
   // Build
   
   internal final override func makeBBox () -> Box3f
   {
      return Box3f (min: -size / 2,
                    max:  size / 2)
   }

   internal final override func build ()
   {
      isSolid     = solid
      hasTexCoord = true
      
      // Size
      
      let x = size .x / 2
      let y = size .y / 2
      let z = size .z / 2

      // Front face
      
      addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], normal: Vector3f (0, 0, 1), point: Vector3f (-x, -y, z))
      addPrimitive (texCoords: [Vector4f (1, 0, 0, 1)], normal: Vector3f (0, 0, 1), point: Vector3f ( x, -y, z))
      addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], normal: Vector3f (0, 0, 1), point: Vector3f ( x,  y, z))

      addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], normal: Vector3f (0, 0, 1), point: Vector3f (-x, -y, z))
      addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], normal: Vector3f (0, 0, 1), point: Vector3f ( x,  y, z))
      addPrimitive (texCoords: [Vector4f (0, 1, 0, 1)], normal: Vector3f (0, 0, 1), point: Vector3f (-x,  y, z))

      // Back face
      
      addPrimitive (texCoords: [Vector4f (1, 0, 0, 1)], normal: Vector3f (0, 0, -1), point: Vector3f (-x, -y, -z))
      addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], normal: Vector3f (0, 0, -1), point: Vector3f (-x,  y, -z))
      addPrimitive (texCoords: [Vector4f (0, 1, 0, 1)], normal: Vector3f (0, 0, -1), point: Vector3f ( x,  y, -z))

      addPrimitive (texCoords: [Vector4f (1, 0, 0, 1)], normal: Vector3f (0, 0, -1), point: Vector3f (-x, -y, -z))
      addPrimitive (texCoords: [Vector4f (0, 1, 0, 1)], normal: Vector3f (0, 0, -1), point: Vector3f ( x,  y, -z))
      addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], normal: Vector3f (0, 0, -1), point: Vector3f ( x, -y, -z))

      // Top face
      
      addPrimitive (texCoords: [Vector4f (0, 1, 0, 1)], normal: Vector3f (0, 1, 0), point: Vector3f (-x, y, -z))
      addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], normal: Vector3f (0, 1, 0), point: Vector3f (-x, y,  z))
      addPrimitive (texCoords: [Vector4f (1, 0, 0, 1)], normal: Vector3f (0, 1, 0), point: Vector3f ( x, y,  z))

      addPrimitive (texCoords: [Vector4f (0, 1, 0, 1)], normal: Vector3f (0, 1, 0), point: Vector3f (-x, y, -z))
      addPrimitive (texCoords: [Vector4f (1, 0, 0, 1)], normal: Vector3f (0, 1, 0), point: Vector3f ( x, y,  z))
      addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], normal: Vector3f (0, 1, 0), point: Vector3f ( x, y, -z))

      // Bottom face
      
      addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], normal: Vector3f (0, -1, 0), point: Vector3f (-x, -y, -z))
      addPrimitive (texCoords: [Vector4f (1, 0, 0, 1)], normal: Vector3f (0, -1, 0), point: Vector3f ( x, -y, -z))
      addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], normal: Vector3f (0, -1, 0), point: Vector3f ( x, -y,  z))

      addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], normal: Vector3f (0, -1, 0), point: Vector3f (-x, -y, -z))
      addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], normal: Vector3f (0, -1, 0), point: Vector3f ( x, -y,  z))
      addPrimitive (texCoords: [Vector4f (0, 1, 0, 1)], normal: Vector3f (0, -1, 0), point: Vector3f (-x, -y,  z))

      // Right face
      
      addPrimitive (texCoords: [Vector4f (1, 0, 0, 1)], normal: Vector3f (1, 0, 0), point: Vector3f (x, -y, -z))
      addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], normal: Vector3f (1, 0, 0), point: Vector3f (x,  y, -z))
      addPrimitive (texCoords: [Vector4f (0, 1, 0, 1)], normal: Vector3f (1, 0, 0), point: Vector3f (x,  y,  z))

      addPrimitive (texCoords: [Vector4f (1, 0, 0, 1)], normal: Vector3f (1, 0, 0), point: Vector3f (x, -y, -z))
      addPrimitive (texCoords: [Vector4f (0, 1, 0, 1)], normal: Vector3f (1, 0, 0), point: Vector3f (x,  y,  z))
      addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], normal: Vector3f (1, 0, 0), point: Vector3f (x, -y,  z))

      // Left face
      
      addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], normal: Vector3f (-1, 0, 0), point: Vector3f (-x, -y, -z))
      addPrimitive (texCoords: [Vector4f (1, 0, 0, 1)], normal: Vector3f (-1, 0, 0), point: Vector3f (-x, -y,  z))
      addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], normal: Vector3f (-1, 0, 0), point: Vector3f (-x,  y,  z))

      addPrimitive (texCoords: [Vector4f (0, 0, 0, 1)], normal: Vector3f (-1, 0, 0), point: Vector3f (-x, -y, -z))
      addPrimitive (texCoords: [Vector4f (1, 1, 0, 1)], normal: Vector3f (-1, 0, 0), point: Vector3f (-x,  y,  z))
      addPrimitive (texCoords: [Vector4f (0, 1, 0, 1)], normal: Vector3f (-1, 0, 0), point: Vector3f (-x,  y, -z))
   }
}
