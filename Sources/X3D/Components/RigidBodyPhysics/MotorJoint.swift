//
//  MotorJoint.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class MotorJoint :
   X3DRigidJointNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "MotorJoint" }
   internal final override class var component      : String { "RigidBodyPhysics" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "joints" }

   // Fields

   @SFBool  public final var autoCalc             : Bool = false
   @SFInt32 public final var enabledAxes          : Int32 = 1
   @SFVec3f public final var motor1Axis           : Vector3f = .zero
   @SFVec3f public final var motor2Axis           : Vector3f = .zero
   @SFVec3f public final var motor3Axis           : Vector3f = .zero
   @SFFloat public final var axis1Angle           : Float = 0
   @SFFloat public final var axis2Angle           : Float = 0
   @SFFloat public final var axis3Angle           : Float = 0
   @SFFloat public final var axis1Torque          : Float = 0
   @SFFloat public final var axis2Torque          : Float = 0
   @SFFloat public final var axis3Torque          : Float = 0
   @SFFloat public final var stop1Bounce          : Float = 0
   @SFFloat public final var stop2Bounce          : Float = 0
   @SFFloat public final var stop3Bounce          : Float = 0
   @SFFloat public final var stop1ErrorCorrection : Float = 0.8
   @SFFloat public final var stop2ErrorCorrection : Float = 0.8
   @SFFloat public final var stop3ErrorCorrection : Float = 0.8
   @SFFloat public final var motor1Angle          : Float = 0
   @SFFloat public final var motor2Angle          : Float = 0
   @SFFloat public final var motor3Angle          : Float = 0
   @SFFloat public final var motor1AngleRate      : Float = 0
   @SFFloat public final var motor2AngleRate      : Float = 0
   @SFFloat public final var motor3AngleRate      : Float = 0

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.MotorJoint)

      addField (.inputOutput,    "metadata",             $metadata)
      addField (.inputOutput,    "forceOutput",          $forceOutput)
      addField (.initializeOnly, "autoCalc",             $autoCalc)
      addField (.inputOutput,    "enabledAxes",          $enabledAxes)
      addField (.inputOutput,    "motor1Axis",           $motor1Axis)
      addField (.inputOutput,    "motor2Axis",           $motor2Axis)
      addField (.inputOutput,    "motor3Axis",           $motor3Axis)
      addField (.inputOutput,    "axis1Angle",           $axis1Angle)
      addField (.inputOutput,    "axis2Angle",           $axis2Angle)
      addField (.inputOutput,    "axis3Angle",           $axis3Angle)
      addField (.inputOutput,    "axis1Torque",          $axis1Torque)
      addField (.inputOutput,    "axis2Torque",          $axis2Torque)
      addField (.inputOutput,    "axis3Torque",          $axis3Torque)
      addField (.inputOutput,    "stop1Bounce",          $stop1Bounce)
      addField (.inputOutput,    "stop2Bounce",          $stop2Bounce)
      addField (.inputOutput,    "stop3Bounce",          $stop3Bounce)
      addField (.inputOutput,    "stop1ErrorCorrection", $stop1ErrorCorrection)
      addField (.inputOutput,    "stop2ErrorCorrection", $stop2ErrorCorrection)
      addField (.inputOutput,    "stop3ErrorCorrection", $stop3ErrorCorrection)
      addField (.outputOnly,     "motor1Angle",          $motor1Angle)
      addField (.outputOnly,     "motor2Angle",          $motor2Angle)
      addField (.outputOnly,     "motor3Angle",          $motor3Angle)
      addField (.outputOnly,     "motor1AngleRate",      $motor1AngleRate)
      addField (.outputOnly,     "motor2AngleRate",      $motor2AngleRate)
      addField (.outputOnly,     "motor3AngleRate",      $motor3AngleRate)
      addField (.inputOutput,    "body1",                $body1)
      addField (.inputOutput,    "body2",                $body2)

      $axis1Angle      .unit = .angle
      $axis2Angle      .unit = .angle
      $axis3Angle      .unit = .angle
      $motor1Angle     .unit = .angle
      $motor2Angle     .unit = .angle
      $motor3Angle     .unit = .angle
      $motor1AngleRate .unit = .angular_rate
      $motor2AngleRate .unit = .angular_rate
      $motor3AngleRate .unit = .angular_rate
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> MotorJoint
   {
      return MotorJoint (with: executionContext)
   }
}
