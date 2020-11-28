//
//  Billboard.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Billboard :
   X3DGroupingNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Billboard" }
   internal final override class var component      : String { "Navigation" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFVec3f public final var axisOfRotation : Vector3f = .yAxis

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Billboard)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "axisOfRotation", $axisOfRotation)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Billboard
   {
      return Billboard (with: executionContext)
   }
   
   // Property access
   
   public final override var bbox : Box3f { matrix * super .bbox }
   
   // Rendering
   
   private final var matrix : Matrix4f = .identity
   
   private final func rotate (modelViewMatrix : Matrix4f) -> Matrix4f
   {
      // throws domain error

      let invModelViewMatrix = modelViewMatrix .inverse
      let billboardToViewer  = normalize (invModelViewMatrix .origin) // Normalized to get work with Geo

      if axisOfRotation == .zero
      {
         let viewerYAxis = normalize (invModelViewMatrix .submatrix * Vector3f .yAxis) // Normalized to get work with Geo

         var x = cross (viewerYAxis, billboardToViewer)
         var y = cross (billboardToViewer, x)
         let z = billboardToViewer

         // Compose rotation

         x = normalize (x)
         y = normalize (y)

         matrix = Matrix4f (columns: (Vector4f (x [0], x [1], x [2], 0),
                                      Vector4f (y [0], y [1], y [2], 0),
                                      Vector4f (z [0], z [1], z [2], 0),
                                      Vector4f (    0,     0,     0, 1)))
      }
      else
      {
         let N1 = cross (axisOfRotation, billboardToViewer) // Normal vector of plane as in specification
         let N2 = cross (axisOfRotation, .zAxis)            // Normal vector of plane between axisOfRotation and zAxis

         matrix = Matrix4f (Rotation4f (from: N2, to: N1))  // Rotate zAxis in plane
      }

      return matrix
   }
   
   internal final override func traverse (_ type: TraverseType, _ renderer: Renderer)
   {
      renderer .modelViewMatrix .push ()
      
      defer { renderer .modelViewMatrix .pop () }
      
      switch type
      {
         case .Camera, .Picking, .Depth:
            renderer .modelViewMatrix .mult (matrix)
         default:
            renderer .modelViewMatrix .mult (rotate (modelViewMatrix: renderer .modelViewMatrix .top))
      }
      
      super .traverse (type, renderer)
   }
}
