//
//  FloatVertexAttribute.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class FloatVertexAttribute :
   X3DVertexAttributeNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "FloatVertexAttribute" }
   internal final override class var component      : String { "Shaders" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "attrib" }

   // Fields

   @SFInt32 public final var numComponents : Int32 = 4
   @MFFloat public final var value         : MFFloat .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.FloatVertexAttribute)

      addField (.inputOutput,    "metadata",      $metadata)
      addField (.initializeOnly, "name",          $name)
      addField (.initializeOnly, "numComponents", $numComponents)
      addField (.inputOutput,    "value",         $value)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> FloatVertexAttribute
   {
      return FloatVertexAttribute (with: executionContext)
   }
}
