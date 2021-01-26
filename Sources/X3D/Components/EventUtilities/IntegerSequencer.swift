//
//  IntegerSequencer.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class IntegerSequencer :
   X3DSequencerNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "IntegerSequencer" }
   internal final override class var component      : String { "EventUtilities" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFInt32 public final var keyValue      : [Int32]
   @SFInt32 public final var value_changed : Int32 = 0

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.IntegerSequencer)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOnly,   "set_fraction",  $set_fraction)
      addField (.inputOnly,   "previous",      $previous)
      addField (.inputOnly,   "next",          $next)
      addField (.inputOutput, "key",           $key)
      addField (.inputOutput, "keyValue",      $keyValue)
      addField (.outputOnly,  "value_changed", $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> IntegerSequencer
   {
      return IntegerSequencer (with: executionContext)
   }

   internal final override func initialize ()
   {
      super .initialize ()

      $keyValue .addInterest ("set_index", IntegerSequencer .set_index, self)
   }
   
   // Property access
   
   internal final override var size : Int { min (Int (Int32 .max), keyValue .count) }
   
   // Event handlers

   internal final override func sequence (index : Int)
   {
      value_changed = keyValue [index]
   }
}
