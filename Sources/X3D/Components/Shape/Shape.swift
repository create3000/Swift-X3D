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
   
   internal final override class var typeName       : String { "Shape" }
   internal final override class var component      : String { "Shape" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

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
            pointer (renderer)
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
   
   private final func pointer (_ renderer : X3DRenderer)
   {
      let browser = renderer .browser
      
      guard let geometryNode = geometryNode else { return }
      
      guard geometryNode .geometryType >= 2 else { return }
      
      let modelViewMatrix    = renderer .modelViewMatrix .top
      let invModelViewMatrix = modelViewMatrix .inverse
      let hitRay             = invModelViewMatrix * renderer .browser .hitRay
      
      guard var intersections = geometryNode .intersects (line: hitRay, modelViewMatrix: modelViewMatrix) else { return }
      
      // Finally we have intersections and must now find the closest hit in front of the camera.
      
      for i in 0 ..< intersections .count
      {
         // Transform hitPoints to absolute space.
         intersections [i] .point = modelViewMatrix * intersections [i] .point
      }
      
      // Find first point that is not greater than near plane;
      
      intersections .sort { $0 .point .z > $1 .point .z }

      let nearValue = -renderer .layerNode .navigationInfoNode .nearValue

      guard let index = intersections .firstIndex (where: { $0 .point .z < nearValue }) else { return }
      
      // Add hit.
      
      var intersection = intersections [index]
      
      // Transform hitNormal to absolute space.
      intersection .normal = normalize (intersection .normal * invModelViewMatrix .submatrix)
      
      browser .addHit (layerNode: renderer .layerNode,
                       layerNumber: renderer .layerNumber,
                       shapeNode: self,
                       intersection: intersection)
   }
   
   internal final override func render (_ context : X3DRenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      appearanceNode! .render (context, renderEncoder)
      geometryNode!   .render (context, renderEncoder)
   }
}
