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
   
   public final override class var typeName       : String { "StaticGroup" }
   public final override class var component      : String { "Grouping" }
   public final override class var componentLevel : Int32 { 3 }
   public final override class var containerField : String { "children" }

   // Fields
   
   @SFVec3f public final var bboxSize   : Vector3f = Vector3f (-1, -1, -1)
   @SFVec3f public final var bboxCenter : Vector3f = Vector3f .zero
   @MFNode  public final var children   : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)

      types .append (.StaticGroup)

      addField (.inputOutput,    "metadata",   $metadata)
      addField (.initializeOnly, "bboxSize",   $bboxSize)
      addField (.initializeOnly, "bboxCenter", $bboxCenter)
      addField (.initializeOnly, "children",   $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> StaticGroup
   {
      return StaticGroup (with: executionContext)
   }
   
   // Bounded object
   
   public final var bbox : Box3f { Box3f () }
}
