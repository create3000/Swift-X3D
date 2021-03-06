//
//  SplinePositionInterpolator2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class SplinePositionInterpolator2D :
   X3DInterpolatorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "SplinePositionInterpolator2D" }
   internal final override class var component      : String { "Interpolation" }
   internal final override class var componentLevel : Int32 { 4 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFBool  public final var closed            : Bool = false
   @MFVec2f public final var keyValue          : [Vector2f]
   @MFVec2f public final var keyVelocity       : [Vector2f]
   @SFBool  public final var normalizeVelocity : Bool = false
   @SFVec2f public final var value_changed     : Vector2f = .zero

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.SplinePositionInterpolator2D)

      addField (.inputOutput, "metadata",          $metadata)
      addField (.inputOnly,   "set_fraction",      $set_fraction)
      addField (.inputOutput, "closed",            $closed)
      addField (.inputOutput, "key",               $key)
      addField (.inputOutput, "keyValue",          $keyValue)
      addField (.inputOutput, "keyVelocity",       $keyVelocity)
      addField (.inputOutput, "normalizeVelocity", $normalizeVelocity)
      addField (.outputOnly,  "value_changed",     $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SplinePositionInterpolator2D
   {
      return SplinePositionInterpolator2D (with: executionContext)
   }
}
