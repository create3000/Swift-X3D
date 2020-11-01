//
//  TimeContext.swift
//  X3D
//
//  Created by Holger Seelig on 07.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation
import simd

public final class X3DTimeContextProperies :
   X3DBaseNode
{
   // Properties
   
   fileprivate final var currentTime      : TimeInterval = Date () .timeIntervalSince1970
   fileprivate final var currentFrameRate : Double = 0
   fileprivate final var currentSpeed     : Double = 0
   fileprivate final var lastPosition     : Vector3d = Vector3d .zero
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
   
   // Operations
   
   fileprivate func advanceTime ()
   {
      let now      = Date () .timeIntervalSince1970
      let interval = now - currentTime

      currentTime      = now
      currentFrameRate = interval != 0 ? 1 / interval : 60

      if let activeLayerNode = browser! .world .layerSetNode? .activeLayerNode
      {
         let cameraSpaceMatrix = activeLayerNode .viewpointNode .cameraSpaceMatrix
         let currentPosition   = Vector3d (Double (cameraSpaceMatrix [3] [0]), Double (cameraSpaceMatrix [3] [1]), Double (cameraSpaceMatrix [3] [2]))

         currentSpeed = length (currentPosition - lastPosition) * currentFrameRate
         lastPosition = currentPosition
      }
      else
      {
         currentSpeed = 0
      }
   }
}

public protocol X3DTimeContext : class
{
   var browser               : X3DBrowser { get }
   var timeContextProperties : X3DTimeContextProperies! { get }
}

extension X3DTimeContext
{
   public var currentTime      : TimeInterval { timeContextProperties .currentTime }
   public var currentFrameRate : Double { timeContextProperties .currentFrameRate }
   public var currentSpeed     : Double { timeContextProperties .currentSpeed }

   internal func advanceTime () { timeContextProperties .advanceTime () }
}
