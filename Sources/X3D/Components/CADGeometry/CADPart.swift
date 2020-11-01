//
//  CADPart.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CADPart :
   X3DGroupingNode,
   X3DProductStructureChildNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "CADPart" }
   public final override class var component      : String { "CADGeometry" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }
   
   // Fields

   @SFString   public final var name             : String = ""
   @SFVec3f    public final var translation      : Vector3f = Vector3f .zero
   @SFRotation public final var rotation         : Rotation4f = Rotation4f .identity
   @SFVec3f    public final var scale            : Vector3f = Vector3f (1, 1, 1)
   @SFRotation public final var scaleOrientation : Rotation4f = Rotation4f .identity
   @SFVec3f    public final var center           : Vector3f = Vector3f .zero

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initProductStructureChildNode ()

      types .append (.CADPart)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOutput,    "name",             $name)
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
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CADPart
   {
      return CADPart (with: executionContext)
   }
}
