//
//  KeySensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class KeySensor :
   X3DKeyDeviceSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "KeySensor" }
   internal final override class var component      : String { "KeyDeviceSensor" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFBool   public final var controlKey       : Bool = false
   @SFBool   public final var shiftKey         : Bool = false
   @SFBool   public final var altKey           : Bool = false
   @SFInt32  public final var actionKeyPress   : Int32 = 0
   @SFInt32  public final var actionKeyRelease : Int32 = 0
   @SFString public final var keyPress         : String = ""
   @SFString public final var keyRelease       : String = ""

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.KeySensor)

      addField (.inputOutput, "metadata",         $metadata)
      addField (.inputOutput, "enabled",          $enabled)
      addField (.outputOnly,  "controlKey",       $controlKey)
      addField (.outputOnly,  "shiftKey",         $shiftKey)
      addField (.outputOnly,  "altKey",           $altKey)
      addField (.outputOnly,  "actionKeyPress",   $actionKeyPress)
      addField (.outputOnly,  "actionKeyRelease", $actionKeyRelease)
      addField (.outputOnly,  "keyPress",         $keyPress)
      addField (.outputOnly,  "keyRelease",       $keyRelease)
      addField (.outputOnly,  "isActive",         $isActive)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> KeySensor
   {
      return KeySensor (with: executionContext)
   }
}
