//
//  StringSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class StringSensor :
   X3DKeyDeviceSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "StringSensor" }
   public final override class var component      : String { "KeyDeviceSensor" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool   public final var deletionAllowed : Bool = true
   @SFString public final var enteredText     : String = ""
   @SFString public final var finalText       : String = ""

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.StringSensor)

      addField (.inputOutput, "metadata",        $metadata)
      addField (.inputOutput, "enabled",         $enabled)
      addField (.inputOutput, "deletionAllowed", $deletionAllowed)
      addField (.outputOnly,  "enteredText",     $enteredText)
      addField (.outputOnly,  "finalText",       $finalText)
      addField (.outputOnly,  "isActive",        $isActive)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> StringSensor
   {
      return StringSensor (with: executionContext)
   }
}
