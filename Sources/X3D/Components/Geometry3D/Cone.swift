//
//  Cone.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation
import ComplexModule

public final class Cone :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Cone" }
   internal final override class var component      : String { "Geometry3D" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFBool  public final var side         : Bool = true
   @SFBool  public final var bottom       : Bool = true
   @SFFloat public final var height       : Float = 2
   @SFFloat public final var bottomRadius : Float = 1
   @SFBool  public final var solid        : Bool = true

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Cone)

      addField (.inputOutput,    "metadata",     $metadata)
      addField (.initializeOnly, "side",         $side)
      addField (.initializeOnly, "bottom",       $bottom)
      addField (.initializeOnly, "height",       $height)
      addField (.initializeOnly, "bottomRadius", $bottomRadius)
      addField (.initializeOnly, "solid",        $solid)

      $height       .unit = .length
      $bottomRadius .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Cone
   {
      return Cone (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      DispatchQueue .main .async
      {
         guard let browser = self .browser else { return }
         
         browser .coneOptions .addInterest ("requestRebuild", { $0 .requestRebuild () }, self)
         
         self .rebuild ()
      }
   }
   
   // Build
   
   internal final override func makeBBox () -> Box3f
   {
      let y1 = height / 2
      let y2 = -y1

      if !side && !bottom
      {
         return .empty
      }

      else if !side
      {
         return Box3f (min: Vector3f (-bottomRadius, y2, -bottomRadius),
                       max: Vector3f ( bottomRadius, y2,  bottomRadius))
      }

      else
      {
         return Box3f (min: Vector3f (-bottomRadius, y2, -bottomRadius),
                       max: Vector3f ( bottomRadius, y1, bottomRadius))
      }
   }

   final override func build ()
   {
      guard let browser = browser else { return }
      
      isSolid     = solid
      hasTexCoord = true

      let uDimension = browser .coneOptions .uDimension

      let y1 = height / 2
      let y2 = -y1
      let nz = Complex (length: 1, phase: -Float .pi / 2 + atan (bottomRadius / height))

      if side
      {
         for i in 0 ..< uDimension
         {
            let u1     = (Float (i) + 0.5) / Float (uDimension)
            let theta1 = 2 * Float .pi * u1
            let n1     = Complex (length: nz .imaginary, phase: theta1)

            let u2     = Float (i) / Float (uDimension)
            let theta2 = 2 * Float .pi * u2
            let p2     = Complex (length: -bottomRadius, phase: theta2)
            let n2     = Complex (length: nz .imaginary, phase: theta2)

            let u3     = (Float (i) + 1) / Float (uDimension)
            let theta3 = 2 * Float .pi * u3
            let p3     = Complex (length: -bottomRadius, phase: theta3)
            let n3     = Complex (length: nz .imaginary, phase: theta3)

            /*    p1
             *   /  \
             *  /    \
             * p2 -- p3
             */

            // p1
            addPrimitive (texCoords: [Vector4f (u1, 1, 0, 1)],
                          normal: Vector3f (n1 .imaginary, nz .real, n1 .real),
                          point: Vector3f (0, y1, 0))

            // p2
            addPrimitive (texCoords: [Vector4f (u2, 0, 0, 1)],
                          normal: Vector3f (n2 .imaginary, nz .real, n2 .real),
                          point: Vector3f (p2 .imaginary, y2, p2 .real))

            // p3
            addPrimitive (texCoords: [Vector4f (u3, 0, 0, 1)],
                          normal: Vector3f (n3 .imaginary , nz .real, n3 .real),
                          point: Vector3f (p3 .imaginary, y2, p3 .real))
         }
      }

      if bottom
      {
         var texCoord = [Vector4f] ()
         var points   = [Vector3f] ()

         for i in (0 ... uDimension - 1) .reversed ()
         {
            let u     = Float (i) / Float (uDimension)
            let theta = 2 * Float .pi * u
            let t     = Complex (length: -1, phase: theta)
            let p     = t * Complex (bottomRadius, 0)

            texCoord .append (Vector4f ((t .imaginary + 1) / 2, (t .real + 1) / 2, 0, 1))
            points   .append (Vector3f (p .imaginary, y2, p .real))
         }
      
         let t0 = texCoord [0]
         let p0 = points [0]

         for i in 1 ..< points .count - 1
         {
            let t1 = texCoord [i]
            let t2 = texCoord [i + 1]
            let p1 = points [i]
            let p2 = points [i + 1]

            addPrimitive (texCoords: [t0],
                          normal: -.yAxis,
                          point: Vector3f (p0 .x, p0 .y, p0 .z))

            addPrimitive (texCoords: [t1],
                          normal: -.yAxis,
                          point: Vector3f (p1 .x, p1 .y, p1 .z))

            addPrimitive (texCoords: [t2],
                          normal: -.yAxis,
                          point: Vector3f (p2 .x, p2 .y, p2 .z))
         }

      }
   }
}
