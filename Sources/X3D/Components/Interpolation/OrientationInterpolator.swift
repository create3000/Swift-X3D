//
//  OrientationInterpolator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class OrientationInterpolator :
   X3DInterpolatorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "OrientationInterpolator" }
   internal final override class var component      : String { "Interpolation" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFRotation public final var keyValue      : [Rotation4f]
   @SFRotation public final var value_changed : Rotation4f = .identity

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.OrientationInterpolator)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOnly,   "set_fraction",  $set_fraction)
      addField (.inputOutput, "key",           $key)
      addField (.inputOutput, "keyValue",      $keyValue)
      addField (.outputOnly,  "value_changed", $value_changed)
      
      $keyValue      .unit = .angle
      $value_changed .unit = .angle
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> OrientationInterpolator
   {
      return OrientationInterpolator (with: executionContext)
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
      
      keyValue .append (contentsOf: repeatElement (keyValue .last ?? .identity, count: key .count - keyValue .count))
   }
   
   internal final override func interpolate (index0 : Int, index1 : Int, weight : Float)
   {
      value_changed = slerp (keyValue [index0], keyValue [index1], t: weight)
   }
}

/*
fileprivate func slerp (_ source : Quaternion4f, _ destination : Quaternion4f, t : Float) -> Quaternion4f?
{
   var dest  = destination
   var cosom = dot (source, dest)

   if cosom <= -1
   {
      return nil
   }

   if cosom >= 1 // both normal vectors are equal
   {
      return dest
   }

   if cosom < 0
   {
      // Reverse signs so we travel the short way round
      cosom = -cosom
      dest  = -dest
   }

   let omega = acos (cosom)
   let sinom = sin  (omega)

   let scale0 = sin ((1 - t) * omega)
   let scale1 = sin (t * omega)

   return (scale0 * source + scale1 * dest) / sinom
}
*/
