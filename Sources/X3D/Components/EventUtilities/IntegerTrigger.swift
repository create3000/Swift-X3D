//
//  IntegerTrigger.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class IntegerTrigger :
   X3DTriggerNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "IntegerTrigger" }
   internal final override class var component      : String { "EventUtilities" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFBool  public final var set_boolean  : Bool = false
   @SFInt32 public final var integerKey   : Int32 = -1
   @SFInt32 public final var triggerValue : Int32 = 0

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.IntegerTrigger)

      addField (.inputOutput, "metadata",     $metadata)
      addField (.inputOnly,   "set_boolean",  $set_boolean)
      addField (.inputOutput, "integerKey",   $integerKey)
      addField (.outputOnly,  "triggerValue", $triggerValue)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> IntegerTrigger
   {
      return IntegerTrigger (with: executionContext)
   }

   internal final override func initialize ()
   {
      super .initialize ()

      $set_boolean .addInterest ("set_boolean_", { $0 .set_boolean_ () }, self)
   }
   
   // Event handlers

   private final func set_boolean_ ()
   {
      triggerValue = integerKey
   }
}
