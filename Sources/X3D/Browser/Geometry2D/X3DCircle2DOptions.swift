//
//  X3DCircleOptions.swift
//  X3D
//
//  Created by Holger Seelig on 11.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import ComplexModule

internal final class X3DCircle2DOptions :
   X3DBaseNode
{
   // Fields
   
   @SFInt32 internal final var dimension : Int32 = 32
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addField (.inputOutput, "dimension", $dimension)
   }
   
   internal final var primitives : [Vector3f]
   {
      var primitives = [Vector3f] ()
      let angle      = 2 * Float .pi / Float (dimension)

      for n in 0 ..< dimension
      {
         let point = Complex (length: 1, phase: angle * Float (n))

         primitives .append (Vector3f (point .real, point .imaginary, 0))
      }
      
      primitives .append (primitives .first!)
      
      return primitives
   }
}
