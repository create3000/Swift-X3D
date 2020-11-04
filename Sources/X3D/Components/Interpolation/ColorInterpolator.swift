//
//  ColorInterpolator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ColorInterpolator :
   X3DInterpolatorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ColorInterpolator" }
   public final override class var component      : String { "Interpolation" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @MFColor public final var keyValue      : MFColor .Value
   @SFColor public final var value_changed : Color3f = Color3f .zero

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ColorInterpolator)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOnly,   "set_fraction",  $set_fraction)
      addField (.inputOutput, "key",           $key)
      addField (.inputOutput, "keyValue",      $keyValue)
      addField (.outputOnly,  "value_changed", $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ColorInterpolator
   {
      return ColorInterpolator (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $keyValue .addInterest (ColorInterpolator .set_keyValue, self)
   }
   
   // Event handlers
   
   internal final override func set_keyValue ()
   {
      guard keyValue .count < key .count else { return }
      
      keyValue .append (contentsOf: repeatElement (keyValue .last ?? Color3f .zero, count: key .count - keyValue .count))
   }
   
   internal final override func interpolate (index0 : Int, index1 : Int, weight : Float)
   {
      value_changed = hsv_mix (keyValue [index0] .hsv, keyValue [index1] .hsv, t: weight) .rgb
   }
}