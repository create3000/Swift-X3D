//
//  SplineScalarInterpolator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class SplineScalarInterpolator :
   X3DInterpolatorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "SplineScalarInterpolator" }
   public final override class var component      : String { "Interpolation" }
   public final override class var componentLevel : Int32 { 4 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool  public final var closed            : Bool = false
   @MFFloat public final var keyValue          : MFFloat .Value
   @MFFloat public final var keyVelocity       : MFFloat .Value
   @SFBool  public final var normalizeVelocity : Bool = false
   @SFFloat public final var value_changed     : Float = 0

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.SplineScalarInterpolator)

      addField (.inputOutput, "metadata",          $metadata)
      addField (.inputOnly,   "set_fraction",      $set_fraction)
      addField (.inputOutput, "closed",            $closed)
      addField (.inputOutput, "key",               $key)
      addField (.inputOutput, "keyValue",          $keyValue)
      addField (.inputOutput, "keyVelocity",       $keyVelocity)
      addField (.inputOutput, "normalizeVelocity", $normalizeVelocity)
      addField (.outputOnly,  "value_changed",     $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SplineScalarInterpolator
   {
      return SplineScalarInterpolator (with: executionContext)
   }
}