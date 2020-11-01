//
//  X3DPointingDeviceSensorNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DPointingDeviceSensorNode :
   X3DChildNode,
   X3DSensorNode
{
   // Fields

   @SFBool   public final var enabled     : Bool = true
   @SFString public final var description : String = ""
   @SFBool   public final var isActive    : Bool = false
   @SFBool   public final var isOver      : Bool = false

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)
      
      initSensorNode ()

      types .append (.X3DPointingDeviceSensorNode)
   }
}
