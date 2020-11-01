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
   
   public final override class var typeName       : String { "IntegerTrigger" }
   public final override class var component      : String { "EventUtilities" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool  public final var set_boolean  : Bool = false
   @SFInt32 public final var integerKey   : Int32 = -1
   @SFInt32 public final var triggerValue : Int32 = 0

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
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
}
