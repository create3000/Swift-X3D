//
//  SquadOrientationInterpolator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class SquadOrientationInterpolator :
   X3DInterpolatorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "SquadOrientationInterpolator" }
   internal final override class var component      : String { "Interpolation" }
   internal final override class var componentLevel : Int32 { 5 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFBool     public final var closed        : Bool = false
   @MFRotation public final var keyValue      : [Rotation4f]
   @SFRotation public final var value_changed : Rotation4f = .identity

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.SquadOrientationInterpolator)

      addField (.inputOutput, "metadata",          $metadata)
      addField (.inputOnly,   "set_fraction",      $set_fraction)
      addField (.inputOutput, "closed",            $closed)
      addField (.inputOutput, "key",               $key)
      addField (.inputOutput, "keyValue",          $keyValue)
      //addField (.inputOutput, "normalizeVelocity", $normalizeVelocity)
      addField (.outputOnly,  "value_changed",     $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SquadOrientationInterpolator
   {
      return SquadOrientationInterpolator (with: executionContext)
   }
}
