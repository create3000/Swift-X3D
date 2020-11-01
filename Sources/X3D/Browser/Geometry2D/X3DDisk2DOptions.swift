//
//  Disk2DOptions.swift
//  X3D
//
//  Created by Holger Seelig on 12.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import ComplexModule

internal final class X3DDisk2DOptions :
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
   
   internal final var circlePrimitives : [Vector3f]
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
      
   internal final var diskPrimitives : [(texCoord : Vector4f, point : Vector3f)]
   {
      let angle      = 2 * Float .pi / Float (dimension)
      var primitives = [(texCoord : Vector4f, point : Vector3f)] ()

      for n in 0 ..< dimension
      {
         let theta1 = angle * Float (n)
         let theta2 = angle * Float (n + 1)

         let texCoord1 = Complex (length: 0.5, phase: theta1) + Complex (0.5, 0.5)
         let texCoord2 = Complex (length: 0.5, phase: theta2) + Complex (0.5, 0.5)
         let point1    = Complex (length: 1, phase: theta1)
         let point2    = Complex (length: 1, phase: theta2)

         // Disk
         
         primitives .append ((Vector4f (0.5, 0.5, 0, 1),
                              Vector3f (0, 0, 0)))
         
         primitives .append ((Vector4f (texCoord1 .real, texCoord1 .imaginary, 0, 1),
                              Vector3f (point1 .real, point1 .imaginary, 0)))
         
         primitives .append ((Vector4f (texCoord2 .real, texCoord2 .imaginary, 0, 1),
                              Vector3f (point2 .real, point2 .imaginary, 0)))
      }
      
      return primitives
   }
}
