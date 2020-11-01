//
//  RigidBody.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class RigidBody :
   X3DNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "RigidBody" }
   public final override class var component      : String { "RigidBodyPhysics" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "bodies" }

   // Fields

   @SFBool     public final var enabled              : Bool = true
   @SFBool     public final var fixed                : Bool = false
   @SFVec3f    public final var position             : Vector3f = Vector3f .zero
   @SFRotation public final var orientation          : Rotation4f = Rotation4f .identity
   @SFVec3f    public final var linearVelocity       : Vector3f = Vector3f .zero
   @SFVec3f    public final var angularVelocity      : Vector3f = Vector3f .zero
   @SFBool     public final var useFiniteRotation    : Bool = false
   @SFVec3f    public final var finiteRotationAxis   : Vector3f = Vector3f .zero
   @SFBool     public final var autoDamp             : Bool = false
   @SFFloat    public final var linearDampingFactor  : Float = 0.001
   @SFFloat    public final var angularDampingFactor : Float = 0.001
   @SFFloat    public final var mass                 : Float = 1
   @SFVec3f    public final var centerOfMass         : Vector3f = Vector3f .zero
   @SFNode     public final var massDensityModel     : X3DNode?
   @SFBool     public final var useGlobalGravity     : Bool = true
   @MFVec3f    public final var forces               : MFVec3f .Value
   @MFVec3f    public final var torques              : MFVec3f .Value
   @SFMatrix3f public final var inertia              : Matrix3f = Matrix3f .identity
   @SFBool     public final var autoDisable          : Bool = false
   @SFFloat    public final var disableTime          : Float = 0
   @SFFloat    public final var disableLinearSpeed   : Float = 0
   @SFFloat    public final var disableAngularSpeed  : Float = 0
   @MFNode     public final var geometry             : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.RigidBody)

      addField (.inputOutput, "metadata",             $metadata)
      addField (.inputOutput, "enabled",              $enabled)
      addField (.inputOutput, "fixed",                $fixed)
      addField (.inputOutput, "position",             $position)
      addField (.inputOutput, "orientation",          $orientation)
      addField (.inputOutput, "linearVelocity",       $linearVelocity)
      addField (.inputOutput, "angularVelocity",      $angularVelocity)
      addField (.inputOutput, "useFiniteRotation",    $useFiniteRotation)
      addField (.inputOutput, "finiteRotationAxis",   $finiteRotationAxis)
      addField (.inputOutput, "autoDamp",             $autoDamp)
      addField (.inputOutput, "linearDampingFactor",  $linearDampingFactor)
      addField (.inputOutput, "angularDampingFactor", $angularDampingFactor)
      addField (.inputOutput, "mass",                 $mass)
      addField (.inputOutput, "inertia",              $inertia)
      addField (.inputOutput, "centerOfMass",         $centerOfMass)
      addField (.inputOutput, "massDensityModel",     $massDensityModel)
      addField (.inputOutput, "useGlobalGravity",     $useGlobalGravity)
      addField (.inputOutput, "forces",               $forces)
      addField (.inputOutput, "torques",              $torques)
      addField (.inputOutput, "autoDisable",          $autoDisable)
      addField (.inputOutput, "disableTime",          $disableTime)
      addField (.inputOutput, "disableLinearSpeed",   $disableLinearSpeed)
      addField (.inputOutput, "disableAngularSpeed",  $disableAngularSpeed)
      addField (.inputOutput, "geometry",             $geometry)

      $position            .unit = .length
      $linearVelocity      .unit = .speed
      $angularVelocity     .unit = .angular_rate
      $mass                .unit = .mass
      $forces              .unit = .force
      $torques             .unit = .force
      $disableLinearSpeed  .unit = .speed
      $disableAngularSpeed .unit = .angular_rate
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> RigidBody
   {
      return RigidBody (with: executionContext)
   }
}
