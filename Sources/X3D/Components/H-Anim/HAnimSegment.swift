//
//  HAnimSegment.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class HAnimSegment :
   X3DGroupingNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "HAnimSegment" }
   internal final override class var component      : String { "H-Anim" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFString public final var name             : String = ""
   @SFFloat  public final var mass             : Float = 0
   @SFVec3f  public final var centerOfMass     : Vector3f = .zero
   @MFFloat  public final var momentsOfInertia : MFFloat .Value = [0, 0, 0, 0, 0, 0, 0, 0, 0]
   @MFNode   public final var displacers       : MFNode <X3DNode> .Value
   @SFNode   public final var coord            : X3DNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.HAnimSegment)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOutput,    "name",             $name)
      addField (.inputOutput,    "mass",             $mass)
      addField (.inputOutput,    "centerOfMass",     $centerOfMass)
      addField (.inputOutput,    "momentsOfInertia", $momentsOfInertia)
      addField (.inputOutput,    "displacers",       $displacers)
      addField (.inputOutput,    "coord",            $coord)
      addField (.initializeOnly, "bboxSize",         $bboxSize)
      addField (.initializeOnly, "bboxCenter",       $bboxCenter)
      addField (.inputOnly,      "addChildren",      $addChildren)
      addField (.inputOnly,      "removeChildren",   $removeChildren)
      addField (.inputOutput,    "children",         $children)

      $mass .unit = .mass
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> HAnimSegment
   {
      return HAnimSegment (with: executionContext)
   }
}
