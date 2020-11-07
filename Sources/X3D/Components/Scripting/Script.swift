//
//  Script.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Script :
   X3DScriptNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Script" }
   internal final override class var component      : String { "Scripting" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFBool public final var directOutput : Bool = false
   @SFBool public final var mustEvaluate : Bool = false

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Script)

      addField (.inputOutput,    "metadata",     $metadata)
      addField (.inputOutput,    "url",          $url)
      addField (.initializeOnly, "directOutput", $directOutput)
      addField (.initializeOnly, "mustEvaluate", $mustEvaluate)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Script
   {
      return Script (with: executionContext)
   }
}
