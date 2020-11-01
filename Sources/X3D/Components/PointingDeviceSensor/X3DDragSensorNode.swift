//
//  X3DDragSensorNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DDragSensorNode :
   X3DPointingDeviceSensorNode
{
   // Fields

   @SFBool  public final var autoOffset         : Bool = true
   @SFVec3f public final var trackPoint_changed : Vector3f = Vector3f .zero

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DDragSensorNode)

      $trackPoint_changed .unit = .length
   }
}
