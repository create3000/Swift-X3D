//
//  BooleanSequencer.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class BooleanSequencer :
   X3DSequencerNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "BooleanSequencer" }
   internal final override class var component      : String { "EventUtilities" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFBool public final var keyValue      : [Bool]
   @SFBool public final var value_changed : Bool = false

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.BooleanSequencer)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOnly,   "set_fraction",  $set_fraction)
      addField (.inputOnly,   "previous",      $previous)
      addField (.inputOnly,   "next",          $next)
      addField (.inputOutput, "key",           $key)
      addField (.inputOutput, "keyValue",      $keyValue)
      addField (.outputOnly,  "value_changed", $value_changed)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> BooleanSequencer
   {
      return BooleanSequencer (with: executionContext)
   }

   internal final override func initialize ()
   {
      super .initialize ()

      $keyValue .addInterest ("set_index", BooleanSequencer .set_index, self)
   }
   
   // Property access
   
   internal final override var size : Int { min (Int (Int32 .max), keyValue .count) }
   
   // Event handlers

   internal final override func sequence (index : Int)
   {
      value_changed = keyValue [index]
   }
}
