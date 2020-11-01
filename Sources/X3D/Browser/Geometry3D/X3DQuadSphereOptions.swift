//
//  X3DQuadSphereOptions.swift
//  X3D
//
//  Created by Holger Seelig on 08.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import ComplexModule

internal final class X3DQuadSphereOptions :
   X3DSphereOptions
{
   // Fields
   
   @SFInt32 internal final var uDimension : Int32 = 32
   @SFInt32 internal final var vDimension : Int32 = 15
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addField (.inputOutput, "uDimension", $uDimension)
      addField (.inputOutput, "vDimension", $vDimension)
   }
   
   internal final override var primitives : [X3DSphereOptionsVertex]
   {
      var primitives = [X3DSphereOptionsVertex] ()
      
      let texCoordIndex = makeTexCoordIndex ()
      let texCoords     = makeTexCoords ()
      let coordIndex    = makeCoordIndex ()
      let points        = makePoints ()

      for i in 0 ..< coordIndex .count
      {
         let texCoord = texCoords [texCoordIndex [i]]
         let point    = points    [coordIndex [i]]
         
         primitives .append (X3DSphereOptionsVertex (texCoord: texCoord,
                                                     point: point))
      }
      
      return primitives
   }
   
   private final func makeTexCoordIndex () -> [Int]
   {
      var texCoordIndex = [Int] ()
      
      var p = 0

      for _ in 0 ..< uDimension
      {
         texCoordIndex .append (p)
         texCoordIndex .append (p + Int (uDimension))
         texCoordIndex .append (p + Int (uDimension) + 1)
         
         p += 1
      }

      for _ in 1 ..< vDimension - 2
      {
         for _ in 0 ..< uDimension
         {
            texCoordIndex .append (p)
            texCoordIndex .append (p + Int (uDimension) + 1)
            texCoordIndex .append (p + Int (uDimension) + 2)
            
            texCoordIndex .append (p)
            texCoordIndex .append (p + Int (uDimension) + 2)
            texCoordIndex .append (p + 1)
            
            p += 1
         }
         
         p += 1
      }

      for _ in 0 ..< uDimension
      {
         texCoordIndex .append (p)
         texCoordIndex .append (p + Int (uDimension) + 1)
         texCoordIndex .append (p + 1)
         
         p += 1
      }

      return texCoordIndex
   }
   
   private final func makeTexCoords () -> [Vector4f]
   {
      var texCoords = [Vector4f] ()
      
      let polOffset = 1 / (2 * Float (uDimension))

      for u in 0 ..< uDimension
      {
         let x = Float (u) / Float (uDimension) + polOffset
         texCoords .append (Vector4f (x, 1, 0, 1))
      }

      for v in 1 ..< vDimension - 1
      {
         let y = Float (v) / Float (vDimension - 1)

         for u in 0 ..< uDimension
         {
            let x = Float (u) / Float (uDimension)
            texCoords .append (Vector4f (x, 1 - y, 0, 1))
         }

         texCoords .append (Vector4f (1, 1 - y, 0, 1))
      }

      for u in 0 ..< uDimension
      {
         let x = Float (u) / Float (uDimension) + polOffset
         texCoords .append (Vector4f (x, 0, 0, 1))
      }

      return texCoords
   }
   
   private final func makeCoordIndex () -> [Int]
   {
      var coordIndex = [Int] ()
      
      var p = 1

      for _ in 0 ..< uDimension - 1
      {
         coordIndex .append (0)
         coordIndex .append (p)
         coordIndex .append (p + 1)
         
         p += 1
      }
      
      coordIndex .append (0)
      coordIndex .append (p)
      coordIndex .append (1)
      
      p = 1

      for _ in 1 ..< vDimension - 2
      {
         for _ in 0 ..< uDimension - 1
         {
            coordIndex .append (p)
            coordIndex .append (p + Int (uDimension))
            coordIndex .append (p + Int (uDimension) + 1)
            
            coordIndex .append (p)
            coordIndex .append (p + Int (uDimension) + 1)
            coordIndex .append (p + 1)
            
            p += 1
         }

         coordIndex .append (p)
         coordIndex .append (p + Int (uDimension))
         coordIndex .append (p + 1)
         
         coordIndex .append (p)
         coordIndex .append (p + 1)
         coordIndex .append (p - Int (uDimension) + 1)
         
         p += 1
      }
      
      let l = p + Int (uDimension)

      for _ in 0 ..< uDimension - 1
      {
         coordIndex .append (p)
         coordIndex .append (l)
         coordIndex .append (p + 1)

         p += 1
      }

      coordIndex .append (p)
      coordIndex .append (l)
      coordIndex .append (p - Int (uDimension) + 1)

      return coordIndex
   }
   
   private final func makePoints () -> [Vector3f]
   {
      var points = [Vector3f] ()
      
      // North pole
      points .append (Vector3f (0, 1, 0))

      // Sphere segments
      for v in 1 ..< vDimension - 1
      {
         let zPlane = Complex (length: 1, phase: -Float .pi * Float (v) / Float (vDimension - 1))

         for u in 0 ..< uDimension
         {
            let yPlane = Complex (length: zPlane .imaginary, phase: 2 * Float .pi * Float (u) / Float (uDimension))

            points .append (Vector3f (yPlane .imaginary, zPlane .real , yPlane .real))
         }
      }

      // South pole
      points .append (Vector3f (0, -1, 0))

      return points
   }
}
