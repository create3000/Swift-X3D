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
   
   public final override class var typeName       : String { "TimeTrigger" }
   public final override class var component      : String { "EventUtilities" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool public final var set_boolean : Bool = false
   @SFTime public final var triggerTime : TimeInterval = 0

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
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
}
