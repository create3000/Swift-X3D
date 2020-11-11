//
//  X3DTouchSensorNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public class X3DTouchSensorNode :
   X3DPointingDeviceSensorNode
{
   // Fields

   @SFTime public final var touchTime : TimeInterval = 0

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DTouchSensorNode)
   }
   
   // Event handlers
   
   internal final override func set_active (active : Bool,
                                            hit : Hit?,
                                            modelViewMatrix : Matrix4f,
                                            projectionMatrix : Matrix4f,
                                            viewport : Vector4i)
   {
      super .set_active (active: active, hit: hit, modelViewMatrix: modelViewMatrix, projectionMatrix: projectionMatrix, viewport: viewport)
      
      guard enabled && isOver && !active else { return }
      
      touchTime = browser! .currentTime
   }
}
