//
//  Matrix3VertexAttribute.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Matrix3VertexAttribute :
   X3DVertexAttributeNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Matrix3VertexAttribute" }
   internal final override class var component      : String { "Shaders" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "attrib" }

   // Fields

   @MFMatrix3f public final var value : MFMatrix3f .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Matrix3VertexAttribute)

      addField (.inputOutput,    "metadata", $metadata)
      addField (.initializeOnly, "name",     $name)
      addField (.inputOutput,    "value",    $value)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Matrix3VertexAttribute
   {
      return Matrix3VertexAttribute (with: executionContext)
   }
}
