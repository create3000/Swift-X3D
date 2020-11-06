//
//  BooleanTrigger.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class BooleanTrigger :
   X3DTriggerNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "BooleanTrigger" }
   public final override class var component      : String { "EventUtilities" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFTime public final var set_triggerTime : TimeInterval = 0
   @SFBool public final var triggerTrue     : Bool = false

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.BooleanTrigger)

      addField (.inputOutput, "metadata",        $metadata)
      addField (.inputOnly,   "set_triggerTime", $set_triggerTime)
      addField (.outputOnly,  "triggerTrue",     $triggerTrue)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> BooleanTrigger
   {
      return BooleanTrigger (with: executionContext)
   }

   internal final override func initialize ()
   {
      super .initialize ()

      $set_triggerTime .addInterest (BooleanTrigger .set_triggerTime_, self)
   }
   
   // Event handlers

   private final func set_triggerTime_ ()
   {
      triggerTrue = true
   }
}
