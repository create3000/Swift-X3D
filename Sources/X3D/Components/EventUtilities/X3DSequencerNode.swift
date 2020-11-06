//
//  X3DSequencerNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DSequencerNode :
   X3DChildNode
{
   // Fields

   @SFFloat public final var set_fraction : Float = 0
   @SFBool  public final var previous     : Bool = false
   @SFBool  public final var next         : Bool = false
   @MFFloat public final var key          : MFFloat .Value
   
   // Properties
   
   private final var index : Int = -1

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DSequencerNode)
   }

   internal override func initialize ()
   {
      super .initialize ()

      $set_fraction .addInterest (X3DSequencerNode .set_fraction_, self)
      $previous     .addInterest (X3DSequencerNode .set_previous,  self)
      $next         .addInterest (X3DSequencerNode .set_next,      self)
      $key          .addInterest (X3DSequencerNode .set_index,     self)
   }
   
   internal var size : Int { 0 }

   private final func set_fraction_ ()
   {
      if key .isEmpty
      {
         return
      }

      var i = 0

      if key .count == 1 || set_fraction <= key .first!
      {
         i = 0
      }

      else if set_fraction >= key .last!
      {
         i = size - 1
      }

      else
      {
         let index = key .upperBound (value: set_fraction, comp: <)
         
         i = index - 1
      }

      if i != index
      {
         if i < size
         {
            index = i
            
            sequence (index: index)
         }
      }
   }

   private final func set_previous ()
   {
      if previous
      {
         if index <= 0
         {
            index = size - 1
         }
         else
         {
            index -= 1
         }

         if index < size
         {
            sequence (index: index)
         }
      }
   }

   private final func set_next ()
   {
      if next
      {
         if index >= size - 1
         {
            index = 0
         }
         else
         {
            index += 1
         }

         if index < size
         {
            sequence (index: index)
         }
      }
   }

   internal final func set_index ()
   {
      index = -1
   }
   
   internal func sequence (index : Int) { }
}
