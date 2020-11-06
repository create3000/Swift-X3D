//
//  Shape.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public final class Shape :
   X3DShapeNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Shape" }
   public final override class var component      : String { "Shape" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Shape)

      addField (.inputOutput,    "metadata",   $metadata)
      addField (.initializeOnly, "bboxSize",   $bboxSize)
      addField (.initializeOnly, "bboxCenter", $bboxCenter)
      addField (.inputOutput,    "appearance", $appearance)
      addField (.inputOutput,    "geometry",   $geometry)
   }
   
   internal final override func create (with executionContext : X3DExecutionContext) -> Shape
   {
      return Shape (with: executionContext)
   }
   
   public final override var bbox : Box3f
   {
      if bboxSize == -.one
      {
         if geometryNode != nil
         {
            return geometryNode! .bbox
         }
         else
         {
            return Box3f ()
         }
      }
      
      return Box3f (size: bboxSize, center: bboxCenter)
   }
   
   // Rendering
   
   internal final override func traverse (_ type : X3DTraverseType, _ renderer : X3DRenderer)
   {
      guard let geometryNode = geometryNode else { return }

      switch type
      {
         case .Pointer:
            break
         case .Camera:
            break
         case .Picking:
            break
         case .Collision:
            break
         case .Depth:
            break
         case .Render:
            renderer .addRenderShape (self)
      }
      
      geometryNode .traverse (type, renderer)
   }
   
   internal final override func render (_ context : X3DRenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      appearanceNode! .render (context, renderEncoder)
      geometryNode! .render (context, renderEncoder)
   }
}
