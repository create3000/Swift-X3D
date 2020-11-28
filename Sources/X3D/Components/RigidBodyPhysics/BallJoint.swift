//
//  BallJoint.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class BallJoint :
   X3DRigidJointNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "BallJoint" }
   internal final override class var component      : String { "RigidBodyPhysics" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "joints" }

   // Fields

   @SFVec3f public final var anchorPoint      : Vector3f = .zero
   @SFVec3f public final var body1AnchorPoint : Vector3f = .zero
   @SFVec3f public final var body2AnchorPoint : Vector3f = .zero

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.BallJoint)

      addField (.inputOutput, "metadata",         $metadata)
      addField (.inputOutput, "forceOutput",      $forceOutput)
      addField (.inputOutput, "anchorPoint",      $anchorPoint)
      addField (.outputOnly,  "body1AnchorPoint", $body1AnchorPoint)
      addField (.outputOnly,  "body2AnchorPoint", $body2AnchorPoint)
      addField (.inputOutput, "body1",            $body1)
      addField (.inputOutput, "body2",            $body2)

      $anchorPoint .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> BallJoint
   {
      return BallJoint (with: executionContext)
   }
}
