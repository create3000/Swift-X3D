//
//  BooleanFilter.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class BooleanFilter :
   X3DChildNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "BooleanFilter" }
   public final override class var component      : String { "EventUtilities" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool public final var set_boolean : Bool = false
   @SFBool public final var inputFalse  : Bool = false
   @SFBool public final var inputTrue   : Bool = false
   @SFBool public final var inputNegate : Bool = false

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.BooleanFilter)

      addField (.inputOutput, "metadata",    $metadata)
      addField (.inputOnly,   "set_boolean", $set_boolean)
      addField (.outputOnly,  "inputFalse",  $inputFalse)
      addField (.outputOnly,  "inputTrue",   $inputTrue)
      addField (.outputOnly,  "inputNegate", $inputNegate)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> BooleanFilter
   {
      return BooleanFilter (with: executionContext)
   }

   internal final override func initialize ()
   {
      super .initialize ()

      $set_boolean .addInterest (BooleanFilter .set_boolean_, self)
   }
   
   // Event handlers

   private final func set_boolean_ ()
   {
      if set_boolean
      {
         inputTrue = true
      }
      else
      {
         inputFalse = false
      }

      inputNegate = !set_boolean
   }
}
