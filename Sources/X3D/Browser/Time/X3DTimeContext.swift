//
//  TimeContext.swift
//  X3D
//
//  Created by Holger Seelig on 07.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation
import simd

internal final class X3DTimeContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate final var currentTime      : TimeInterval = Date () .timeIntervalSince1970
   fileprivate final var currentSpeed     : Double = 0
   fileprivate final var currentFrameRate : Double = 0
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
         let currentPosition   = Vector3d (cameraSpaceMatrix .origin)

         currentSpeed = length (currentPosition - lastPosition) * currentFrameRate
         lastPosition = currentPosition
      }
      else
      {
         currentSpeed = 0
      }
   }
}

internal protocol X3DTimeContext : class
{
   var browser               : X3DBrowser { get }
   var timeContextProperties : X3DTimeContextProperties! { get }
}

extension X3DTimeContext
{
   internal var currentTime      : TimeInterval { timeContextProperties .currentTime }
   internal var currentSpeed     : Double { timeContextProperties .currentSpeed }
   internal var currentFrameRate : Double { timeContextProperties .currentFrameRate }

   internal func advanceTime () { timeContextProperties .advanceTime () }
}
