//
//  Contact.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Contact :
   X3DNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Contact" }
   internal final override class var component      : String { "RigidBodyPhysics" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFVec3f  public final var position                 : Vector3f = .zero
   @SFVec3f  public final var contactNormal            : Vector3f = Vector3f (0, 1, 0)
   @SFFloat  public final var depth                    : Float = 0
   @SFVec3f  public final var frictionDirection        : Vector3f = Vector3f (0, 1, 0)
   @MFString public final var appliedParameters        : [String] = ["BOUNCE"]
   @SFFloat  public final var bounce                   : Float = 0
   @SFFloat  public final var minBounceSpeed           : Float = 0
   @SFVec2f  public final var frictionCoefficients     : Vector2f = .zero
   @SFVec2f  public final var surfaceSpeed             : Vector2f = .zero
   @SFVec2f  public final var slipCoefficients         : Vector2f = .zero
   @SFFloat  public final var softnessConstantForceMix : Float = 0.0001
   @SFFloat  public final var softnessErrorCorrection  : Float = 0.8
   @SFNode   public final var geometry1                : X3DNode?
   @SFNode   public final var geometry2                : X3DNode?
   @SFNode   public final var body1                    : X3DNode?
   @SFNode   public final var body2                    : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Contact)

      addField (.inputOutput, "metadata",                 $metadata)
      addField (.inputOutput, "position",                 $position)
      addField (.inputOutput, "contactNormal",            $contactNormal)
      addField (.inputOutput, "depth",                    $depth)
      addField (.inputOutput, "frictionDirection",        $frictionDirection)
      addField (.inputOutput, "appliedParameters",        $appliedParameters)
      addField (.inputOutput, "bounce",                   $bounce)
      addField (.inputOutput, "minBounceSpeed",           $minBounceSpeed)
      addField (.inputOutput, "frictionCoefficients",     $frictionCoefficients)
      addField (.inputOutput, "surfaceSpeed",             $surfaceSpeed)
      addField (.inputOutput, "slipCoefficients",         $slipCoefficients)
      addField (.inputOutput, "softnessConstantForceMix", $softnessConstantForceMix)
      addField (.inputOutput, "softnessErrorCorrection",  $softnessErrorCorrection)
      addField (.inputOutput, "geometry1",                $geometry1)
      addField (.inputOutput, "geometry2",                $geometry2)
      addField (.inputOutput, "body1",                    $body1)
      addField (.inputOutput, "body2",                    $body2)

      $position                 .unit = .length
      $depth                    .unit = .length
      $minBounceSpeed           .unit = .speed
      $surfaceSpeed             .unit = .speed
      $softnessConstantForceMix .unit = .force
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Contact
   {
      return Contact (with: executionContext)
   }
}
