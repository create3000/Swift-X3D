//
//  ArcClose2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation
import ComplexModule

public final class ArcClose2D :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ArcClose2D" }
   public final override class var component      : String { "Geometry2D" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "geometry" }

   // Fields

   @SFString public final var closureType : String = "PIE"
   @SFFloat  public final var startAngle  : Float = 0
   @SFFloat  public final var endAngle    : Float = 1.570796
   @SFFloat  public final var radius      : Float = 1
   @SFBool   public final var solid       : Bool = false

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ArcClose2D)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.initializeOnly, "closureType", $closureType)
      addField (.initializeOnly, "startAngle",  $startAngle)
      addField (.initializeOnly, "endAngle",    $endAngle)
      addField (.initializeOnly, "radius",      $radius)
      addField (.initializeOnly, "solid",       $solid)

      $startAngle .unit = .angle
      $endAngle   .unit = .angle
      $radius     .unit = .length
      
      geometryType = 2
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ArcClose2D
   {
      return ArcClose2D (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      DispatchQueue .main .async
      {
         guard let browser = self .browser else { return }
         
         browser .arcClose2DOptions .addInterest (ArcClose2D .requestRebuild, self)
         
         self .rebuild ()
      }
   }
   
   // Build
   
   private final var sweepAngle : Float
   {
      let start = interval (startAngle, low: 0, high: Float .pi * 2)
      let end   = interval (endAngle,   low: 0, high: Float .pi * 2)

      if start == end
      {
         return Float .pi * 2
      }

      let sweepAngle = abs (end - start)

      if start > end
      {
         return Float .pi * 2 - sweepAngle
      }

      if !sweepAngle .isNaN
      {
         return sweepAngle
      }
      
      // We must test for NAN, as NAN to int32_t is undefined.
      return 0
   }

   internal final override func build ()
   {
      isSolid     = solid
      hasTexCoord = true
      
      let sweepAngle = self .sweepAngle
      let steps      = Int (sweepAngle * Float (browser! .arcClose2DOptions .dimension) / (Float .pi * 2))
      let radius     = abs (self .radius)
      let chord      = closureType == "CHORD"
      var texCoords  = [Complex <Float>] ()
      var points     = [Complex <Float>] ()

      let steps_1 = steps - 1

      for n in 0 ..< steps
      {
         let t     = Float (n) / Float (steps_1)
         let theta = startAngle + (sweepAngle * t)

         texCoords .append (Complex (length: 0.5, phase: theta) + Complex (0.5, 0.5))
         points    .append (Complex (length: radius, phase: theta))
      }

      if chord
      {
         let t0 = texCoords [0]
         let p0 = points [0]

         for i in 1 ..< steps_1
         {
            let t1 = texCoords [i]
            let t2 = texCoords [i + 1]
            let p1 = points [i]
            let p2 = points [i + 1]
            
            addPrimitive (texCoords: [Vector4f (t0 .real, t0 .imaginary, 0, 1)],
                          normal: .zAxis,
                          point: Vector3f (p0 .real, p0 .imaginary, 0))
            
            addPrimitive (texCoords: [Vector4f (t1 .real, t1 .imaginary, 0, 1)],
                          normal: .zAxis,
                          point: Vector3f (p1 .real, p1 .imaginary, 0))
            
            addPrimitive (texCoords: [Vector4f (t2 .real, t2 .imaginary, 0, 1)],
                          normal: .zAxis,
                          point: Vector3f (p2 .real, p2 .imaginary, 0))
         }
      }
      else
      {
         for i in 0 ..< steps_1
         {
            let t1 = texCoords [i]
            let t2 = texCoords [i + 1]
            let p1 = points [i]
            let p2 = points [i + 1]
            
            addPrimitive (texCoords: [Vector4f (0.5, 0.5, 0, 1)],
                          normal: .zAxis,
                          point: Vector3f (0, 0, 0))
            
            addPrimitive (texCoords: [Vector4f (t1 .real, t1 .imaginary, 0, 1)],
                          normal: .zAxis,
                          point: Vector3f (p1 .real, p1 .imaginary, 0))
            
            addPrimitive (texCoords: [Vector4f (t2 .real, t2 .imaginary, 0, 1)],
                          normal: .zAxis,
                          point: Vector3f (p2 .real, p2 .imaginary, 0))
         }
      }
   }
}
