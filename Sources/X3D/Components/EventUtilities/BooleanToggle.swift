//
//  BooleanToggle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class BooleanToggle :
   X3DChildNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "BooleanToggle" }
   internal final override class var component      : String { "EventUtilities" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFBool public final var set_boolean : Bool = false
   @SFBool public final var toggle      : Bool = false

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.BooleanToggle)

      addField (.inputOutput, "metadata",    $metadata)
      addField (.inputOnly,   "set_boolean", $set_boolean)
      addField (.inputOutput, "toggle",      $toggle)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> BooleanToggle
   {
      return BooleanToggle (with: executionContext)
   }

   internal final override func initialize ()
   {
      super .initialize ()

      $set_boolean .addInterest (BooleanToggle .set_boolean_, self)
   }
   
   // Event handlers

   private final func set_boolean_ ()
   {
      if set_boolean
      {
         toggle = !toggle
      }
   }
}
