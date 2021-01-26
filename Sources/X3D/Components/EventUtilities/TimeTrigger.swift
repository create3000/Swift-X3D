//
//  TimeTrigger.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class TimeTrigger :
   X3DTriggerNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TimeTrigger" }
   internal final override class var component      : String { "EventUtilities" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFBool public final var set_boolean : Bool = false
   @SFTime public final var triggerTime : TimeInterval = 0

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TimeTrigger)

      addField (.inputOutput, "metadata",    $metadata)
      addField (.inputOnly,   "set_boolean", $set_boolean)
      addField (.outputOnly,  "triggerTime", $triggerTime)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TimeTrigger
   {
      return TimeTrigger (with: executionContext)
   }

   internal final override func initialize ()
   {
      super .initialize ()

      $set_boolean .addInterest ("set_boolean_", TimeTrigger .set_boolean_, self)
   }
   
   // Event handlers

   private final func set_boolean_ ()
   {
      triggerTime = browser! .currentTime
   }
}
