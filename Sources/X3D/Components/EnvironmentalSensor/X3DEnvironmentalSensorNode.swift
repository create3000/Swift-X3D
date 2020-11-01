//
//  X3DEnvironmentalSensorNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public class X3DEnvironmentalSensorNode :
   X3DChildNode,
   X3DSensorNode
{
   // Fields

   @SFBool  public final var enabled   : Bool = true
   @SFVec3f public final var size      : Vector3f = Vector3f .zero
   @SFVec3f public final var center    : Vector3f = Vector3f .zero
   @SFTime  public final var enterTime : TimeInterval = 0
   @SFTime  public final var exitTime  : TimeInterval = 0
   @SFBool  public final var isActive  : Bool = false

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)
      
      initSensorNode ()

      types .append (.X3DEnvironmentalSensorNode)

      $size   .unit = .length
      $center .unit = .length
   }
}
