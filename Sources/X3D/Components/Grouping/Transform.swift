//
//  Transform.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Transform :
   X3DGroupingNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Transform" }
   public final override class var component      : String { "Grouping" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }
   
   // Fields

   @SFVec3f    public final var translation      : Vector3f = Vector3f .zero
   @SFRotation public final var rotation         : Rotation4f = Rotation4f .identity
   @SFVec3f    public final var scale            : Vector3f = Vector3f (1, 1, 1)
   @SFRotation public final var scaleOrientation : Rotation4f = Rotation4f .identity
   @SFVec3f    public final var center           : Vector3f = Vector3f .zero

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Transform)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOutput,    "translation",      $translation)
      addField (.inputOutput,    "rotation",         $rotation)
      addField (.inputOutput,    "scale",            $scale)
      addField (.inputOutput,    "scaleOrientation", $scaleOrientation)
      addField (.inputOutput,    "center",           $center)
      addField (.initializeOnly, "bboxSize",         $bboxSize)
      addField (.initializeOnly, "bboxCenter",       $bboxCenter)
      addField (.inputOnly,      "addChildren",      $addChildren)
      addField (.inputOnly,      "removeChildren",   $removeChildren)
      addField (.inputOutput,    "children",         $children)
      
      $translation .unit = .length
      $center      .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Transform
   {
      return Transform (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      addInterest (Transform .eventsProcessed, self)
      
      eventsProcessed ()
   }
   
   // Event handlers
   
   private final var matrix : Matrix4f = Matrix4f .identity

   private final func eventsProcessed ()
   {
      matrix = compose_transformation_matrix (translation: translation,
                                              rotation: rotation,
                                              scale: scale,
                                              scaleOrientation: scaleOrientation,
                                              center: center)
   }
   
   // Rendering
   
   internal final override func traverse (_ type : X3DTraverseType, _ renderer : X3DRenderer)
   {
      renderer .modelViewMatrix .push ()
      renderer .modelViewMatrix .mult (matrix)
      
      defer { renderer .modelViewMatrix .pop () }

      super .traverse (type, renderer)
   }
}
