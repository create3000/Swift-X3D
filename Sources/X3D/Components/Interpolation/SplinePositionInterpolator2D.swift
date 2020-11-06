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
   
   public final override class var typeName       : String { "SplinePositionInterpolator2D" }
   public final override class var component      : String { "Interpolation" }
   public final override class var componentLevel : Int32 { 4 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool  public final var closed            : Bool = false
   @MFVec2f public final var keyValue          : MFVec2f .Value
   @MFVec2f public final var keyVelocity       : MFVec2f .Value
   @SFBool  public final var normalizeVelocity : Bool = false
   @SFVec2f public final var value_changed     : Vector2f = .zero

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
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
