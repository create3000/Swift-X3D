//
//  ComposedShader.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ComposedShader :
   X3DShaderNode,
   X3DProgrammableShaderObject,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ComposedShader" }
   public final override class var component      : String { "Shaders" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "shaders" }

   // Fields

   @MFNode public final var parts : MFNode <X3DNode> .Value
   
   // Properties
   
   public final override var canUserDefinedFields : Bool { true }
   
   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initProgrammableShaderObject ()

      types .append (.ComposedShader)

      addField (.inputOutput,    "metadata",   $metadata)
      addField (.inputOnly,      "activate",   $activate)
      addField (.outputOnly,     "isSelected", $isSelected)
      addField (.outputOnly,     "isValid",    $isValid)
      addField (.initializeOnly, "language",   $language)
      addField (.inputOutput,    "parts",      $parts)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ComposedShader
   {
      return ComposedShader (with: executionContext)
   }
}
