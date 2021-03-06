//
//  Transform.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Transform :
   X3DGroupingNode,
   X3DTransformObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Transform" }
   internal final override class var component      : String { "Grouping" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }
   
   // Fields

   @SFVec3f    public final var translation      : Vector3f = .zero
   @SFRotation public final var rotation         : Rotation4f = .identity
   @SFVec3f    public final var scale            : Vector3f = Vector3f (1, 1, 1)
   @SFRotation public final var scaleOrientation : Rotation4f = .identity
   @SFVec3f    public final var center           : Vector3f = .zero

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
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
      
      addInterest ("eventsProcessed", { $0 .eventsProcessed () }, self)
      
      eventsProcessed ()
   }
   
   // Event handlers
   
   // Bounded object
   
   public final override var bbox : Box3f { matrix * super .bbox }

   public private(set) final var matrix : Matrix4f = .identity
   
   public func setMatrix (_ matrix : Matrix4f)
   {
      setMatrix (matrix, with: center)
   }

   public func setMatrix (_ matrix : Matrix4f, with center: Vector3f)
   {
      let components = decompose_transformation_matrix (matrix, center: center)
      
      translation      = components .translation
      rotation         = components .rotation
      scale            = components .scale
      scaleOrientation = components .scaleOrientation
     
      self .center = center
   }

   private final func eventsProcessed ()
   {
      matrix = compose_transformation_matrix (translation: translation,
                                              rotation: rotation,
                                              scale: scale,
                                              scaleOrientation: scaleOrientation,
                                              center: center)
   }
   
   // Rendering
   
   internal final override func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      renderer .modelViewMatrix .push ()
      renderer .modelViewMatrix .mult (matrix)
      
      defer { renderer .modelViewMatrix .pop () }

      super .traverse (type, renderer)
   }
}
