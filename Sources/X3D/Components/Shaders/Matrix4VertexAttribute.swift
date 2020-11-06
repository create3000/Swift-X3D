//
//  Matrix4VertexAttribute.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Matrix4VertexAttribute :
   X3DVertexAttributeNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Matrix4VertexAttribute" }
   public final override class var component      : String { "Shaders" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "attrib" }

   // Fields

   @MFMatrix4f public final var value : MFMatrix4f .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Matrix4VertexAttribute)

      addField (.inputOutput,    "metadata", $metadata)
      addField (.initializeOnly, "name",     $name)
      addField (.inputOutput,    "value",    $value)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Matrix4VertexAttribute
   {
      return Matrix4VertexAttribute (with: executionContext)
   }
}
