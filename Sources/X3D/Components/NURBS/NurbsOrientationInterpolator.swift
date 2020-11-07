//
//  NurbsOrientationInterpolator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class NurbsOrientationInterpolator :
   X3DChildNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "NurbsOrientationInterpolator" }
   internal final override class var component      : String { "NURBS" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFFloat    public final var set_fraction  : Float = 0
   @SFInt32    public final var order         : Int32 = 3
   @MFDouble   public final var knot          : MFDouble .Value
   @MFDouble   public final var weight        : MFDouble .Value
   @SFNode     public final var controlPoint  : X3DNode?
   @SFRotation public final var value_changed : Rotation4f = .identity

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.NurbsOrientationInterpolator)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOnly,   "set_fraction",  $set_fraction)
      addField (.inputOutput, "order",         $order)
      addField (.inputOutput, "knot",          $knot)
      addField (.inputOutput, "weight",        $weight)
      addField (.inputOutput, "controlPoint",  $controlPoint)
      addField (.outputOnly,  "value_changed", $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> NurbsOrientationInterpolator
   {
      return NurbsOrientationInterpolator (with: executionContext)
   }
}
