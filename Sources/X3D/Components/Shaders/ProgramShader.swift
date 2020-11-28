//
//  ProgramShader.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ProgramShader :
   X3DShaderNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ProgramShader" }
   internal final override class var component      : String { "Shaders" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "shaders" }

   // Fields

   @MFNode public final var programs : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ProgramShader)

      addField (.inputOutput,    "metadata",   $metadata)
      addField (.inputOnly,      "activate",   $activate)
      addField (.outputOnly,     "isSelected", $isSelected)
      addField (.outputOnly,     "isValid",    $isValid)
      addField (.initializeOnly, "language",   $language)
      addField (.inputOutput,    "programs",   $programs)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ProgramShader
   {
      return ProgramShader (with: executionContext)
   }
}
