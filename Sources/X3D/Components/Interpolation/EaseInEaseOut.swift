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
   
   internal final override class var typeName       : String { "EaseInEaseOut" }
   internal final override class var component      : String { "Interpolation" }
   internal final override class var componentLevel : Int32 { 4 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFVec2f public final var easeInEaseOut            : [Vector2f]
   @SFFloat public final var modifiedFraction_changed : Float = 0

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
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
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $easeInEaseOut .addInterest ("set_keyValue", { $0 .set_keyValue () }, self)
   }
   
   // Event handlers
   
   internal final override func set_keyValue ()
   {
      guard easeInEaseOut .count < key .count else { return }
      
      easeInEaseOut .append (contentsOf: repeatElement (easeInEaseOut .last ?? .zero, count: key .count - easeInEaseOut .count))
   }

   internal final override func interpolate (index0 : Int, index1 : Int, weight : Float)
   {
      var easeOut = easeInEaseOut [index0] .y
      var easeIn  = easeInEaseOut [index1] .x
      let sum     = easeOut + easeIn

      if sum < 0
      {
         modifiedFraction_changed = weight
      }
      else
      {
         if sum > 1
         {
            easeIn  /= sum
            easeOut /= sum
         }

         let t = 1 / (2 - easeOut - easeIn)

         if weight < easeOut
         {
            modifiedFraction_changed = (t / easeOut) * pow (weight, 2)
         }
         else if weight <= 1 - easeIn // Spec says (weight < 1 - easeIn), but then we get a NaN below if easeIn == 0.
         {
            modifiedFraction_changed = t * (2 * weight - easeOut)
         }
         else
         {
            modifiedFraction_changed = 1 - (t * pow (1 - weight, 2) / easeIn)
         }
      }
   }
}
