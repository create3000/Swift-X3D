//
//  PositionInterpolator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PositionInterpolator :
   X3DInterpolatorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "PositionInterpolator" }
   internal final override class var component      : String { "Interpolation" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFVec3f public final var keyValue      : [Vector3f]
   @SFVec3f public final var value_changed : Vector3f = .zero

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PositionInterpolator)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOnly,   "set_fraction",  $set_fraction)
      addField (.inputOutput, "key",           $key)
      addField (.inputOutput, "keyValue",      $keyValue)
      addField (.outputOnly,  "value_changed", $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PositionInterpolator
   {
      return PositionInterpolator (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $keyValue .addInterest ("set_keyValue", { $0 .set_keyValue () }, self)
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
