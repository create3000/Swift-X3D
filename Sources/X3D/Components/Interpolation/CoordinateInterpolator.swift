//
//  CoordinateInterpolator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import simd

public final class CoordinateInterpolator :
   X3DInterpolatorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "CoordinateInterpolator" }
   internal final override class var component      : String { "Interpolation" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "children" }

   // Fields

   @MFVec3f public final var keyValue      : MFVec3f .Value
   @MFVec3f public final var value_changed : MFVec3f .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.CoordinateInterpolator)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOnly,   "set_fraction",  $set_fraction)
      addField (.inputOutput, "key",           $key)
      addField (.inputOutput, "keyValue",      $keyValue)
      addField (.outputOnly,  "value_changed", $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CoordinateInterpolator
   {
      return CoordinateInterpolator (with: executionContext)
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
         value_changed [i] = mix (keyValue [i0 + i],
                                  keyValue [i1 + i],
                                  t: weight)
      }
   }
}
