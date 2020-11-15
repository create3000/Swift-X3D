//
//  ScalarInterpolator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ScalarInterpolator :
   X3DInterpolatorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ScalarInterpolator" }
   internal final override class var component      : String { "Interpolation" }
   internal final override class var componentLevel : Int32 { 4 }
   internal final override class var containerField : String { "children" }

   // Fields

   @MFFloat public final var keyValue      : [Float]
   @SFFloat public final var value_changed : Float = 0

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ScalarInterpolator)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOnly,   "set_fraction",  $set_fraction)
      addField (.inputOutput, "key",           $key)
      addField (.inputOutput, "keyValue",      $keyValue)
      addField (.outputOnly,  "value_changed", $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ScalarInterpolator
   {
      return ScalarInterpolator (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $keyValue .addInterest ("set_keyValue", ScalarInterpolator .set_keyValue, self)
   }
   
   // Event handlers
   
   internal final override func set_keyValue ()
   {
      guard keyValue .count < key .count else { return }
      
      keyValue .append (contentsOf: repeatElement (keyValue .last ?? 0, count: key .count - keyValue .count))
   }
   
   internal final override func interpolate (index0 : Int, index1 : Int, weight : Float)
   {
      value_changed = simd_mix (keyValue [index0], keyValue [index1], weight)
   }
}
