//
//  RigidBodyCollection.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class RigidBodyCollection :
   X3DChildNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "RigidBodyCollection" }
   public final override class var component      : String { "RigidBodyPhysics" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool  public final var enabled                 : Bool = true
   @MFNode  public final var set_contacts            : MFNode <X3DNode> .Value
   @SFVec3f public final var gravity                 : Vector3f = Vector3f (0, -9.8, 0)
   @SFBool  public final var preferAccuracy          : Bool = false
   @SFFloat public final var errorCorrection         : Float = 0.8
   @SFInt32 public final var iterations              : Int32 = 10
   @SFFloat public final var constantForceMix        : Float = 0.0001
   @SFFloat public final var maxCorrectionSpeed      : Float = -1
   @SFFloat public final var contactSurfaceThickness : Float = 0
   @SFBool  public final var autoDisable             : Bool = false
   @SFFloat public final var disableTime             : Float = 0
   @SFFloat public final var disableLinearSpeed      : Float = 0
   @SFFloat public final var disableAngularSpeed     : Float = 0
   @SFNode  public final var collider                : X3DNode?
   @MFNode  public final var bodies                  : MFNode <X3DNode> .Value
   @MFNode  public final var joints                  : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.RigidBodyCollection)

      addField (.inputOutput,    "metadata",                $metadata)
      addField (.inputOutput,    "enabled",                 $enabled)
      addField (.inputOnly,      "set_contacts",            $set_contacts)
      addField (.inputOutput,    "gravity",                 $gravity)
      addField (.inputOutput,    "preferAccuracy",          $preferAccuracy)
      addField (.inputOutput,    "errorCorrection",         $errorCorrection)
      addField (.inputOutput,    "iterations",              $iterations)
      addField (.inputOutput,    "constantForceMix",        $constantForceMix)
      addField (.inputOutput,    "maxCorrectionSpeed",      $maxCorrectionSpeed)
      addField (.inputOutput,    "contactSurfaceThickness", $contactSurfaceThickness)
      addField (.inputOutput,    "autoDisable",             $autoDisable)
      addField (.inputOutput,    "disableTime",             $disableTime)
      addField (.inputOutput,    "disableLinearSpeed",      $disableLinearSpeed)
      addField (.inputOutput,    "disableAngularSpeed",     $disableAngularSpeed)
      addField (.initializeOnly, "collider",                $collider)
      addField (.inputOutput,    "bodies",                  $bodies)
      addField (.inputOutput,    "joints",                  $joints)

      $gravity                 .unit = .acceleration
      $constantForceMix        .unit = .force
      $maxCorrectionSpeed      .unit = .speed
      $contactSurfaceThickness .unit = .length
      $disableLinearSpeed      .unit = .length
      $disableAngularSpeed     .unit = .angular_rate
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> RigidBodyCollection
   {
      return RigidBodyCollection (with: executionContext)
   }
}
