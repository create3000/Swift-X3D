//
//  NormalInterpolator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class NormalInterpolator :
   X3DInterpolatorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "NormalInterpolator" }
   internal final override class var component      : String { "Interpolation" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFVec3f public final var keyValue      : [Vector3f]
   @MFVec3f public final var value_changed : [Vector3f]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.NormalInterpolator)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOnly,   "set_fraction",  $set_fraction)
      addField (.inputOutput, "key",           $key)
      addField (.inputOutput, "keyValue",      $keyValue)
      addField (.outputOnly,  "value_changed", $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> NormalInterpolator
   {
      return NormalInterpolator (with: executionContext)
   }
   
   // Event handlers
   
   internal final override func interpolate (index0 : Int, index1 : Int, weight : Float)
   {
      let size = key .count > 1 ? keyValue .count / key .count : 0

      let i0 = index0 * size
      let i1 = i0 + size

      value_changed .resize (size, fillWith: .zero)

      for i in 0 ..< size
      {
         value_changed [i] = slerp (keyValue [i0 + i],
                                    keyValue [i1 + i],
                                    t: weight)
      }
   }
}
