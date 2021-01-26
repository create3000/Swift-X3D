//
//  Viewport.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Viewport :
   X3DViewportNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Viewport" }
   internal final override class var component      : String { "Layering" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFFloat public final var clipBoundary : [Float] = [0, 1, 0, 1]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Viewport)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "clipBoundary",   $clipBoundary)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Viewport
   {
      return Viewport (with: executionContext)
   }
   
   // Property access
   
   private final var left : Float
   {
      clipBoundary .count > 0 ? clipBoundary [0] : 0
   }
   
   private final var right : Float
   {
      clipBoundary .count > 1 ? clipBoundary [1] : 1
   }
   
   private final var bottom : Float
   {
      clipBoundary .count > 2 ? clipBoundary [2] : 0
   }
   
   private final var top : Float
   {
      clipBoundary .count > 3 ? clipBoundary [3] : 1
   }
   
   internal final override func makeRectangle (with browser : X3DBrowser) -> Vector4i
   {
      let viewport = browser .viewport

      let left   = Int32 (Float (viewport [2]) * self .left)
      let right  = Int32 (Float (viewport [2]) * self .right)
      let bottom = Int32 (Float (viewport [3]) * self .bottom)
      let top    = Int32 (Float (viewport [3]) * self .top)
      
      return Vector4i (left, bottom, max (0, right - left), max (0, top - bottom))
   }
}
