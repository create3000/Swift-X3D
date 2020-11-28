//
//  CollisionCollection.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CollisionCollection :
   X3DChildNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "CollisionCollection" }
   internal final override class var component      : String { "RigidBodyPhysics" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "collider" }

   // Fields

   @SFBool   public final var enabled                  : Bool = true
   @MFString public final var appliedParameters        : [String] = ["BOUNCE"]
   @SFFloat  public final var bounce                   : Float = 0
   @SFFloat  public final var minBounceSpeed           : Float = 0.1
   @SFVec2f  public final var frictionCoefficients     : Vector2f = .zero
   @SFVec2f  public final var surfaceSpeed             : Vector2f = .zero
   @SFVec2f  public final var slipFactors              : Vector2f = .zero
   @SFFloat  public final var softnessConstantForceMix : Float = 0.0001
   @SFFloat  public final var softnessErrorCorrection  : Float = 0.8
   @MFNode   public final var collidables              : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.CollisionCollection)

      addField (.inputOutput, "metadata",                 $metadata)
      addField (.inputOutput, "enabled",                  $enabled)
      addField (.inputOutput, "appliedParameters",        $appliedParameters)
      addField (.inputOutput, "bounce",                   $bounce)
      addField (.inputOutput, "minBounceSpeed",           $minBounceSpeed)
      addField (.inputOutput, "frictionCoefficients",     $frictionCoefficients)
      addField (.inputOutput, "surfaceSpeed",             $surfaceSpeed)
      addField (.inputOutput, "slipFactors",              $slipFactors)
      addField (.inputOutput, "softnessConstantForceMix", $softnessConstantForceMix)
      addField (.inputOutput, "softnessErrorCorrection",  $softnessErrorCorrection)
      addField (.inputOutput, "collidables",              $collidables)

      $minBounceSpeed           .unit = .speed
      $surfaceSpeed             .unit = .speed
      $softnessConstantForceMix .unit = .force
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CollisionCollection
   {
      return CollisionCollection (with: executionContext)
   }
}
