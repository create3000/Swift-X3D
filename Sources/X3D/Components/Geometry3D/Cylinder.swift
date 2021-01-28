//
//  Cylinder.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation
import ComplexModule

public final class Cylinder :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Cylinder" }
   internal final override class var component      : String { "Geometry3D" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "geometry" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFBool  public final var top    : Bool = true
   @SFBool  public final var side   : Bool = true
   @SFBool  public final var bottom : Bool = true
   @SFFloat public final var height : Float = 2
   @SFFloat public final var radius : Float = 1
   @SFBool  public final var solid  : Bool = true

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Cylinder)

      addField (.inputOutput,    "metadata", $metadata)
      addField (.initializeOnly, "top",      $top)
      addField (.initializeOnly, "side",     $side)
      addField (.initializeOnly, "bottom",   $bottom)
      addField (.initializeOnly, "height",   $height)
      addField (.initializeOnly, "radius",   $radius)
      addField (.initializeOnly, "solid",    $solid)

      $height .unit = .length
      $radius .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Cylinder
   {
      return Cylinder (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      DispatchQueue .main .async
      {
         guard let browser = self .browser else { return }
         
         browser .cylinderOptions .addInterest ("requestRebuild", { $0 .requestRebuild () }, self)
         
         self .rebuild ()
      }
   }
   
   // Build
   
   internal final override func makeBBox () -> Box3f
   {
      let y1 = height / 2
      let y2 = -y1

      if !top && !side && !bottom
      {
         return .empty
      }

      else if !top && !side
      {
         return Box3f (min: Vector3f (-radius, y2, -radius),
                       max: Vector3f ( radius, y2,  radius))
      }

      else if !bottom && !side
      {
         return Box3f (min: Vector3f (-radius, y1, -radius),
                       max: Vector3f ( radius, y1,  radius))
      }

      else
      {
         return Box3f (min: Vector3f (-radius, y2, -radius),
                       max: Vector3f ( radius, y1,  radius))
      }
   }

   internal final override func build ()
   {
      guard let browser = browser else { return }
      
      isSolid     = solid
      hasTexCoord = true

      let uDimension = browser .cylinderOptions .uDimension

      let y1 = height / 2
      let y2 = -y1

      if side
      {
         for i in 0 ..< uDimension
         {
            let u1     = Float (i) / Float (uDimension)
            let theta1 = 2 * Float .pi * u1
            let n1     = Complex (length: -1, phase: theta1)
            let p1     = n1 * Complex (radius, 0)

            let u2     = Float (i + 1) / Float (uDimension)
            let theta2 = 2 * Float .pi * u2
            let n2     = Complex (length: -1, phase: theta2)
            let p2     = n2 * Complex (radius, 0)

            // p1 - p4
            //  | \ |
            // p2 - p3

            // Triangle one

            // p1
            addPrimitive (texCoords: [Vector4f (u1, 1, 0, 1)],
                          normal: Vector3f (n1 .imaginary, 0, n1 .real),
                          point: Vector3f (p1 .imaginary, y1, p1 .real))

            // p2
            addPrimitive (texCoords: [Vector4f (u1, 0, 0, 1)],
                          normal: Vector3f (n1 .imaginary, 0, n1 .real),
                          point: Vector3f (p1 .imaginary, y2, p1 .real))

            // p3
            addPrimitive (texCoords: [Vector4f (u2, 0, 0, 1)],
                          normal: Vector3f (n2 .imaginary, 0, n2 .real),
                          point: Vector3f (p2 .imaginary, y2, p2 .real))

            // Triangle two

            // p1
            addPrimitive (texCoords: [Vector4f (u1, 1, 0, 1)],
                          normal: Vector3f (n1 .imaginary, 0, n1 .real),
                          point: Vector3f (p1 .imaginary, y1, p1 .real))

            // p3
            addPrimitive (texCoords: [Vector4f (u2, 0, 0, 1)],
                          normal: Vector3f (n2 .imaginary, 0, n2 .real),
                          point: Vector3f (p2 .imaginary, y2, p2 .real))

            // p4
            addPrimitive (texCoords: [Vector4f (u2, 1, 0, 1)],
                          normal: Vector3f (n2 .imaginary, 0, n2 .real),
                          point: Vector3f (p2 .imaginary, y1, p2 .real))
         }
      }

      if top
      {
         var texCoord = [Vector4f] ()
         var points   = [Vector3f] ()

         for i in 0 ..< uDimension
         {
            let u     = Float (i) / Float (uDimension)
            let theta = 2 * Float .pi * u
            let t     = Complex (length: -1, phase: theta)
            let p     = t * Complex (radius, 0)

            texCoord .append (Vector4f ((t .imaginary + 1) / 2, -(t .real - 1) / 2, 0, 1))
            points   .append (Vector3f (p .imaginary, y1, p .real))
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
                          normal: .yAxis,
                          point: Vector3f (p0 .x, p0 .y, p0 .z))

            addPrimitive (texCoords: [t1],
                          normal: .yAxis,
                          point: Vector3f (p1 .x, p1 .y, p1 .z))

            addPrimitive (texCoords: [t2],
                          normal: .yAxis,
                          point: Vector3f (p2 .x, p2 .y, p2 .z))
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
            let p     = t * Complex (radius, 0)

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
