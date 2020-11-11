//
//  File.swift
//  
//
//  Created by Holger Seelig on 11.11.20.
//

internal final class PointingDeviceSensorContainer
{
   // Properties
   
   private final var pointingDeviceSensorNode : X3DPointingDeviceSensorNode
   private final var modelViewMatrix          : Matrix4f
   private final var projectionMatrix         : Matrix4f
   private final var viewport                 : Vector4i
   
   // Construction
   
   internal init (pointingDeviceSensorNode : X3DPointingDeviceSensorNode,
                  modelViewMatrix : Matrix4f,
                  projectionMatrix : Matrix4f,
                  viewport : Vector4i)
   {
      self .pointingDeviceSensorNode = pointingDeviceSensorNode
      self .modelViewMatrix          = modelViewMatrix
      self .projectionMatrix         = projectionMatrix
      self .viewport                 = viewport
   }
   
   internal final func set_over (over : Bool, hit : Hit?)
   {
      pointingDeviceSensorNode .set_over (over: over,
                                          hit: hit,
                                          modelViewMatrix: modelViewMatrix,
                                          projectionMatrix: projectionMatrix,
                                          viewport: viewport)
   }
   
   internal final func set_active (active : Bool, hit : Hit?)
   {
      pointingDeviceSensorNode .set_active (active: active,
                                            hit: hit,
                                            modelViewMatrix: modelViewMatrix,
                                            projectionMatrix: projectionMatrix,
                                            viewport: viewport)
   }
   
   internal final func set_motion (hit : Hit?)
   {
      pointingDeviceSensorNode .set_motion (hit: hit)
   }
}

extension PointingDeviceSensorContainer :
   Hashable
{
   public static func == (lhs : PointingDeviceSensorContainer, rhs : PointingDeviceSensorContainer) -> Bool
   {
      return lhs .pointingDeviceSensorNode === rhs .pointingDeviceSensorNode
   }
   
   public final func hash (into hasher: inout Hasher)
   {
      hasher .combine (pointingDeviceSensorNode .hashValue)
   }
}
