//
//  UniversalJoint.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class UniversalJoint :
   X3DRigidJointNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "UniversalJoint" }
   public final override class var component      : String { "RigidBodyPhysics" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "joints" }

   // Fields

   @SFVec3f public final var anchorPoint          : Vector3f = Vector3f .zero
   @SFVec3f public final var axis1                : Vector3f = Vector3f .zero
   @SFVec3f public final var axis2                : Vector3f = Vector3f .zero
   @SFFloat public final var stop1Bounce          : Float = 0
   @SFFloat public final var stop2Bounce          : Float = 0
   @SFFloat public final var stop1ErrorCorrection : Float = 0.8
   @SFFloat public final var stop2ErrorCorrection : Float = 0.8
   @SFVec3f public final var body1AnchorPoint     : Vector3f = Vector3f .zero
   @SFVec3f public final var body2AnchorPoint     : Vector3f = Vector3f .zero
   @SFVec3f public final var body1Axis            : Vector3f = Vector3f .zero
   @SFVec3f public final var body2Axis            : Vector3f = Vector3f .zero

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.UniversalJoint)

      addField (.inputOutput, "metadata",             $metadata)
      addField (.inputOutput, "forceOutput",          $forceOutput)
      addField (.inputOutput, "anchorPoint",          $anchorPoint)
      addField (.inputOutput, "axis1",                $axis1)
      addField (.inputOutput, "axis2",                $axis2)
      addField (.inputOutput, "stop1Bounce",          $stop1Bounce)
      addField (.inputOutput, "stop2Bounce",          $stop2Bounce)
      addField (.inputOutput, "stop1ErrorCorrection", $stop1ErrorCorrection)
      addField (.inputOutput, "stop2ErrorCorrection", $stop2ErrorCorrection)
      addField (.outputOnly,  "body1AnchorPoint",     $body1AnchorPoint)
      addField (.outputOnly,  "body2AnchorPoint",     $body2AnchorPoint)
      addField (.outputOnly,  "body1Axis",            $body1Axis)
      addField (.outputOnly,  "body2Axis",            $body2Axis)
      addField (.inputOutput, "body1",                $body1)
      addField (.inputOutput, "body2",                $body2)

      $anchorPoint      .unit = .length
      $body1AnchorPoint .unit = .length
      $body2AnchorPoint .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> UniversalJoint
   {
      return UniversalJoint (with: executionContext)
   }
}
