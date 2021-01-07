//
//  X3DParser.swift
//  X3D
//
//  Created by Holger Seelig on 16.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal class X3DParser
{
   // Execution context
   
   internal final var executionContexts = [X3DExecutionContext] ()
   internal final var executionContext : X3DExecutionContext { executionContexts .last! }
   
   // Proto context
   
   internal final var protos = [X3DProtoDeclaration] ()
   internal final var proto : X3DProtoDeclaration { protos .last! }
   
   internal final var isInsideProtoDefinition : Bool { !protos .isEmpty }
   
   // Units
   
   internal final func fromUnit (_ category : X3DUnitCategory, value : Double) -> Double
   {
      return executionContext .fromUnit (category, value: value)
   }

   internal final func fromUnit (_ category : X3DUnitCategory, value : Float) -> Float
   {
      return executionContext .fromUnit (category, value: value)
   }
}
