//
//  EaseInEaseOut.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class EaseInEaseOut :
   X3DInterpolatorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "EaseInEaseOut" }
   public final override class var component      : String { "Interpolation" }
   public final override class var componentLevel : Int32 { 4 }
   public final override class var containerField : String { "children" }

   // Fields

   @MFVec2f public final var easeInEaseOut            : MFVec2f .Value
   @SFFloat public final var modifiedFraction_changed : Float = 0

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.EaseInEaseOut)

      addField (.inputOutput, "metadata",                 $metadata)
      addField (.inputOnly,   "set_fraction",             $set_fraction)
      addField (.inputOutput, "key",                      $key)
      addField (.inputOutput, "easeInEaseOut",            $easeInEaseOut)
      addField (.outputOnly,  "modifiedFraction_changed", $modifiedFraction_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> EaseInEaseOut
   {
      return EaseInEaseOut (with: executionContext)
   }
}
