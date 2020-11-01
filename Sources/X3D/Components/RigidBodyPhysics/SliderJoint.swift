//
//  SliderJoint.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class SliderJoint :
   X3DRigidJointNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "SliderJoint" }
   public final override class var component      : String { "RigidBodyPhysics" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "joints" }

   // Fields

   @SFVec3f public final var axis                : Vector3f = Vector3f (0, 1, 0)
   @SFFloat public final var minSeparation       : Float = 0
   @SFFloat public final var maxSeparation       : Float = 1
   @SFFloat public final var sliderForce         : Float = 0
   @SFFloat public final var stopBounce          : Float = 0
   @SFFloat public final var stopErrorCorrection : Float = 1
   @SFFloat public final var separation          : Float = 0
   @SFFloat public final var separationRate      : Float = 0

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.SliderJoint)

      addField (.inputOutput, "metadata",            $metadata)
      addField (.inputOutput, "forceOutput",         $forceOutput)
      addField (.inputOutput, "axis",                $axis)
      addField (.inputOutput, "minSeparation",       $minSeparation)
      addField (.inputOutput, "maxSeparation",       $maxSeparation)
      addField (.inputOutput, "sliderForce",         $sliderForce)
      addField (.inputOutput, "stopBounce",          $stopBounce)
      addField (.inputOutput, "stopErrorCorrection", $stopErrorCorrection)
      addField (.outputOnly,  "separation",          $separation)
      addField (.outputOnly,  "separationRate",      $separationRate)
      addField (.inputOutput, "body1",               $body1)
      addField (.inputOutput, "body2",               $body2)

      $minSeparation  .unit = .length
      $maxSeparation  .unit = .length
      $sliderForce    .unit = .force
      $separation     .unit = .force
      $separationRate .unit = .speed
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SliderJoint
   {
      return SliderJoint (with: executionContext)
   }
}
