//
//  SingleAxisHingeJoint.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class SingleAxisHingeJoint :
   X3DRigidJointNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "SingleAxisHingeJoint" }
   public final override class var component      : String { "RigidBodyPhysics" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "joints" }

   // Fields

   @SFVec3f public final var anchorPoint         : Vector3f = Vector3f .zero
   @SFVec3f public final var axis                : Vector3f = Vector3f .zero
   @SFFloat public final var minAngle            : Float = -3.14159
   @SFFloat public final var maxAngle            : Float = 3.14159
   @SFFloat public final var stopBounce          : Float = 0
   @SFFloat public final var stopErrorCorrection : Float = 0.8
   @SFVec3f public final var body1AnchorPoint    : Vector3f = Vector3f .zero
   @SFVec3f public final var body2AnchorPoint    : Vector3f = Vector3f .zero
   @SFFloat public final var angle               : Float = 0
   @SFFloat public final var angleRate           : Float = 0

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.SingleAxisHingeJoint)

      addField (.inputOutput, "metadata",            $metadata)
      addField (.inputOutput, "forceOutput",         $forceOutput)
      addField (.inputOutput, "anchorPoint",         $anchorPoint)
      addField (.inputOutput, "axis",                $axis)
      addField (.inputOutput, "minAngle",            $minAngle)
      addField (.inputOutput, "maxAngle",            $maxAngle)
      addField (.inputOutput, "stopBounce",          $stopBounce)
      addField (.inputOutput, "stopErrorCorrection", $stopErrorCorrection)
      addField (.outputOnly,  "body1AnchorPoint",    $body1AnchorPoint)
      addField (.outputOnly,  "body2AnchorPoint",    $body2AnchorPoint)
      addField (.outputOnly,  "angle",               $angle)
      addField (.outputOnly,  "angleRate",           $angleRate)
      addField (.inputOutput, "body1",               $body1)
      addField (.inputOutput, "body2",               $body2)

      $anchorPoint      .unit = .length
      $minAngle         .unit = .angle
      $maxAngle         .unit = .angle
      $body1AnchorPoint .unit = .length
      $body2AnchorPoint .unit = .length
      $angle            .unit = .angle
      $angleRate        .unit = .angular_rate
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SingleAxisHingeJoint
   {
      return SingleAxisHingeJoint (with: executionContext)
   }
}
