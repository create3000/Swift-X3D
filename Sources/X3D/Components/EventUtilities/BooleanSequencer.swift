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
   
   public final override class var typeName       : String { "BooleanSequencer" }
   public final override class var component      : String { "EventUtilities" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @MFBool public final var keyValue      : MFBool .Value
   @SFBool public final var value_changed : Bool = false

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
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

      $keyValue .addInterest (BooleanSequencer .set_index, self)
   }
   
   // Property access
   
   internal final override var size : Int { min (Int (Int32 .max), keyValue .count) }
   
   // Event handlers

   internal final override func sequence (index : Int)
   {
      value_changed = keyValue [index]
   }
}
