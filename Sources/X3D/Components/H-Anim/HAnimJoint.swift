//
//  HAnimJoint.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class HAnimJoint :
   X3DGroupingNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "HAnimJoint" }
   public final override class var component      : String { "H-Anim" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFString   public final var name             : String = ""
   @SFVec3f    public final var translation      : Vector3f = .zero
   @SFRotation public final var rotation         : Rotation4f = .identity
   @SFVec3f    public final var scale            : Vector3f = Vector3f (1, 1, 1)
   @SFRotation public final var scaleOrientation : Rotation4f = .identity
   @SFVec3f    public final var center           : Vector3f = .zero
   @MFFloat    public final var llimit           : MFFloat .Value
   @MFFloat    public final var ulimit           : MFFloat .Value
   @SFRotation public final var limitOrientation : Rotation4f = .identity
   @MFFloat    public final var stiffness        : MFFloat .Value = [0, 0, 0]
   @MFInt32    public final var skinCoordIndex   : MFInt32 .Value
   @MFFloat    public final var skinCoordWeight  : MFFloat .Value
   @MFNode     public final var displacers       : MFNode <X3DNode> .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.HAnimJoint)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOutput,    "name",             $name)
      addField (.inputOutput,    "translation",      $translation)
      addField (.inputOutput,    "rotation",         $rotation)
      addField (.inputOutput,    "scale",            $scale)
      addField (.inputOutput,    "scaleOrientation", $scaleOrientation)
      addField (.inputOutput,    "center",           $center)
      addField (.inputOutput,    "llimit",           $llimit)
      addField (.inputOutput,    "ulimit",           $ulimit)
      addField (.inputOutput,    "limitOrientation", $limitOrientation)
      addField (.inputOutput,    "stiffness",        $stiffness)
      addField (.inputOutput,    "skinCoordIndex",   $skinCoordIndex)
      addField (.inputOutput,    "skinCoordWeight",  $skinCoordWeight)
      addField (.inputOutput,    "displacers",       $displacers)
      addField (.initializeOnly, "bboxSize",         $bboxSize)
      addField (.initializeOnly, "bboxCenter",       $bboxCenter)
      addField (.inputOnly,      "addChildren",      $addChildren)
      addField (.inputOnly,      "removeChildren",   $removeChildren)
      addField (.inputOutput,    "children",         $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> HAnimJoint
   {
      return HAnimJoint (with: executionContext)
   }
}
