//
//  X3DInterpolatorNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DInterpolatorNode :
   X3DChildNode
{
   // Fields

   @SFFloat public final var set_fraction : Float = 0
   @MFFloat public final var key          : [Float]

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DInterpolatorNode)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      // If an X3DInterpolatorNode value_changed outputOnly field is read before it receives any inputs,
      // keyValue[0] is returned if keyValue is not empty. If keyValue is empty (i.e., [ ]), the initial
      // value for the respective field type is returned (EXAMPLE  (0, 0, 0) for SFVec3f)

      $set_fraction .addInterest (X3DInterpolatorNode .set_fraction_, self)
      $key          .addInterest (X3DInterpolatorNode .set_key,       self)

      set_key ()

      if !key .isEmpty
      {
         interpolate (index0: 0, index1: 0, weight: 0)
      }
   }

   // Event handlers
   
   private final func set_fraction_ ()
   {
      if key .isEmpty
      {
         return
      }

      if key .count == 1
      {
         interpolate (index0: 0, index1: 0, weight: 0)
         return
      }

      if set_fraction <= key [0]
      {
         interpolate (index0: 0, index1: 1, weight: 0)
         return
      }

      if set_fraction >= key [key .count - 1]
      {
         return interpolate (index0: key .count - 2, index1: key .count - 1, weight: 1)
      }
      
      let index1 = key .upperBound (value: set_fraction, comp: <)

      if (index1 != key .count)
      {
         let index0 = index1 - 1
         let weight = (set_fraction - key [index0]) / (key [index1] - key [index0])

         interpolate (index0: index0, index1: index1, weight: clamp (weight, min: 0, max: 1))
      }
   }
   
   internal final func set_key ()
   {
      set_keyValue ()
   }
   
   internal func set_keyValue () { }
   
   internal func interpolate (index0 : Int, index1 : Int, weight : Float) { }
}
