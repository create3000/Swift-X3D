//
//  PositionInterpolator2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import simd

public final class PositionInterpolator2D :
   X3DInterpolatorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "PositionInterpolator2D" }
   public final override class var component      : String { "Interpolation" }
   public final override class var componentLevel : Int32 { 4 }
   public final override class var containerField : String { "children" }

   // Fields

   @MFVec2f public final var keyValue      : MFVec2f .Value
   @SFVec2f public final var value_changed : Vector2f = .zero

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PositionInterpolator2D)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOnly,   "set_fraction",  $set_fraction)
      addField (.inputOutput, "key",           $key)
      addField (.inputOutput, "keyValue",      $keyValue)
      addField (.outputOnly,  "value_changed", $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PositionInterpolator2D
   {
      return PositionInterpolator2D (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $keyValue .addInterest (PositionInterpolator2D .set_keyValue, self)
   }
   
   // Event handlers
   
   internal final override func set_keyValue ()
   {
      guard keyValue .count < key .count else { return }
      
      keyValue .append (contentsOf: repeatElement (keyValue .last ?? .zero, count: key .count - keyValue .count))
   }
   
   internal final override func interpolate (index0 : Int, index1 : Int, weight : Float)
   {
      value_changed = mix (keyValue [index0], keyValue [index1], t: weight)
   }
}
