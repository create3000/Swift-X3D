//
//  Arc2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation
import Metal
import ComplexModule

public final class Arc2D :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Arc2D" }
   internal final override class var component      : String { "Geometry2D" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "geometry" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFFloat public final var startAngle : Float = 0
   @SFFloat public final var endAngle   : Float = 1.570796
   @SFFloat public final var radius     : Float = 1

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Arc2D)

      addField (.inputOutput,    "metadata",   $metadata)
      addField (.initializeOnly, "startAngle", $startAngle)
      addField (.initializeOnly, "endAngle",   $endAngle)
      addField (.initializeOnly, "radius",     $radius)

      $startAngle .unit = .angle
      $endAngle   .unit = .angle
      $radius     .unit = .length
      
      geometryType  = 1
      primitiveType = .lineStrip
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Arc2D
   {
      return Arc2D (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      DispatchQueue .main .async
      {
         guard let browser = self .browser else { return }
         
         browser .arc2DOptions .addInterest ("requestRebuild", { $0 .requestRebuild () }, self)
         
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
      guard let browser = browser else { return }
      
      let sweepAngle = self .sweepAngle
      let circle     = sweepAngle == Float .pi * 2
      var steps      = Int (sweepAngle * Float (browser .arc2DOptions .dimension) / (Float .pi * 2))
      let radius     = abs (self .radius)

      steps = max (3, steps)
      
      let steps_1 = circle ? steps : steps - 1

      for n in 0 ..< steps
      {
         let t     = Float (n) / Float (steps_1)
         let theta = startAngle + (sweepAngle * t)
         let point = Complex (length: radius, phase: theta)

         addPrimitive (point: Vector3f (point .real, point .imaginary, 0))
      }
      
      if circle
      {
         let point = Complex (length: radius, phase: startAngle)

         addPrimitive (point: Vector3f (point .real, point .imaginary, 0))
      }
  }
   
   // Rendering
   
   internal final override func render (_ context : RenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      renderLines (context, renderEncoder)
   }
}
