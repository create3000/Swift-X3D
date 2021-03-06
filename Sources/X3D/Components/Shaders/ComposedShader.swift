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
   
   internal final override class var typeName       : String { "ComposedShader" }
   internal final override class var component      : String { "Shaders" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "shaders" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @MFNode public final var parts : [X3DNode?]
   
   // Properties
   
   public final override var canUserDefinedFields : Bool { true }
   
   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
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
