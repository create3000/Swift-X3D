//
//  DoubleAxisHingeJoint.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class DoubleAxisHingeJoint :
   X3DRigidJointNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "DoubleAxisHingeJoint" }
   internal final override class var component      : String { "RigidBodyPhysics" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "joints" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFVec3f public final var anchorPoint               : Vector3f = .zero
   @SFVec3f public final var axis1                     : Vector3f = .zero
   @SFVec3f public final var axis2                     : Vector3f = .zero
   @SFFloat public final var minAngle1                 : Float = -3.14159
   @SFFloat public final var maxAngle1                 : Float = 3.14159
   @SFFloat public final var desiredAngularVelocity1   : Float = 0
   @SFFloat public final var desiredAngularVelocity2   : Float = 0
   @SFFloat public final var maxTorque1                : Float = 0
   @SFFloat public final var maxTorque2                : Float = 0
   @SFFloat public final var stopBounce1               : Float = 0
   @SFFloat public final var stopConstantForceMix1     : Float = 0.001
   @SFFloat public final var stopErrorCorrection1      : Float = 0.8
   @SFFloat public final var suspensionForce           : Float = 0
   @SFFloat public final var suspensionErrorCorrection : Float = 0.8
   @SFVec3f public final var body1AnchorPoint          : Vector3f = .zero
   @SFVec3f public final var body2AnchorPoint          : Vector3f = .zero
   @SFVec3f public final var body1Axis                 : Vector3f = .zero
   @SFVec3f public final var body2Axis                 : Vector3f = .zero
   @SFFloat public final var hinge1Angle               : Float = 0
   @SFFloat public final var hinge2Angle               : Float = 0
   @SFFloat public final var hinge1AngleRate           : Float = 0
   @SFFloat public final var hinge2AngleRate           : Float = 0

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.DoubleAxisHingeJoint)

      addField (.inputOutput, "metadata",                  $metadata)
      addField (.inputOutput, "forceOutput",               $forceOutput)
      addField (.inputOutput, "anchorPoint",               $anchorPoint)
      addField (.inputOutput, "axis1",                     $axis1)
      addField (.inputOutput, "axis2",                     $axis2)
      addField (.inputOutput, "minAngle1",                 $minAngle1)
      addField (.inputOutput, "maxAngle1",                 $maxAngle1)
      addField (.inputOutput, "desiredAngularVelocity1",   $desiredAngularVelocity1)
      addField (.inputOutput, "desiredAngularVelocity2",   $desiredAngularVelocity2)
      addField (.inputOutput, "maxTorque1",                $maxTorque1)
      addField (.inputOutput, "maxTorque2",                $maxTorque2)
      addField (.inputOutput, "stopBounce1",               $stopBounce1)
      addField (.inputOutput, "stopConstantForceMix1",     $stopConstantForceMix1)
      addField (.inputOutput, "stopErrorCorrection1",      $stopErrorCorrection1)
      addField (.inputOutput, "suspensionForce",           $suspensionForce)
      addField (.inputOutput, "suspensionErrorCorrection", $suspensionErrorCorrection)
      addField (.outputOnly,  "body1AnchorPoint",          $body1AnchorPoint)
      addField (.outputOnly,  "body2AnchorPoint",          $body2AnchorPoint)
      addField (.outputOnly,  "body1Axis",                 $body1Axis)
      addField (.outputOnly,  "body2Axis",                 $body2Axis)
      addField (.outputOnly,  "hinge1Angle",               $hinge1Angle)
      addField (.outputOnly,  "hinge2Angle",               $hinge2Angle)
      addField (.outputOnly,  "hinge1AngleRate",           $hinge1AngleRate)
      addField (.outputOnly,  "hinge2AngleRate",           $hinge2AngleRate)
      addField (.inputOutput, "body1",                     $body1)
      addField (.inputOutput, "body2",                     $body2)

      $anchorPoint             .unit = .length
      $minAngle1               .unit = .angle
      $maxAngle1               .unit = .angle
      $desiredAngularVelocity1 .unit = .angular_rate
      $desiredAngularVelocity2 .unit = .angular_rate
      $stopConstantForceMix1   .unit = .force
      $suspensionForce         .unit = .force
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> DoubleAxisHingeJoint
   {
      return DoubleAxisHingeJoint (with: executionContext)
   }
}
