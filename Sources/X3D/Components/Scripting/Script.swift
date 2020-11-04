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
   
   public final override class var typeName       : String { "Script" }
   public final override class var component      : String { "Scripting" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool public final var directOutput : Bool = false
   @SFBool public final var mustEvaluate : Bool = false

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
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