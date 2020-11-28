//
//  StaticGroup.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class StaticGroup :
   X3DChildNode,
   X3DBoundedObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "StaticGroup" }
   internal final override class var component      : String { "Grouping" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "children" }

   // Fields
   
   @SFVec3f public final var bboxSize   : Vector3f = -.one
   @SFVec3f public final var bboxCenter : Vector3f = .zero
   @MFNode  public final var children   : [X3DNode?]
   
   // Properties
   
   @SFNode private final var groupNode : Group!

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      self .groupNode = Group (with: executionContext)
      
      super .init (executionContext .browser!, executionContext)
      
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)

      types .append (.StaticGroup)

      addField (.inputOutput,    "metadata",   $metadata)
      addField (.initializeOnly, "bboxSize",   $bboxSize)
      addField (.initializeOnly, "bboxCenter", $bboxCenter)
      addField (.initializeOnly, "children",   $children)
      
      addChildObjects ($groupNode)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> StaticGroup
   {
      return StaticGroup (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $bboxSize   .addFieldInterest (to: groupNode .$bboxSize)
      $bboxCenter .addFieldInterest (to: groupNode .$bboxCenter)
      $children   .addFieldInterest (to: groupNode .$children)
      
      groupNode .isPrivate  = true
      groupNode .bboxSize   = bboxSize
      groupNode .bboxCenter = bboxCenter
      
      groupNode .children .append (contentsOf: children)
      groupNode .setup ()
   }
   
   // Bounded object
   
   public final var bbox : Box3f { groupNode .bbox }
   
   // Rendering
   
   internal final override func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      groupNode .traverse (type, renderer)
   }
}
