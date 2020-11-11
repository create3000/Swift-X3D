//
//  File.swift
//  
//
//  Created by Holger Seelig on 11.11.20.
//

internal final class PointingDeviceSensorContainer
{
   // Properties
   
   private final unowned var pointingDeviceSensorNode : X3DPointingDeviceSensorNode
   private final var modelViewMatrix                  : Matrix4f
   private final var projectionMatrix                 : Matrix4f
   private final var viewport                         : Vector4i
   
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
}

extension PointingDeviceSensorContainer :
   Hashable
{
   public static func == (lhs : PointingDeviceSensorContainer, rhs : PointingDeviceSensorContainer) -> Bool
   {
      return lhs === rhs
   }
   
   public final func hash (into hasher: inout Hasher)
   {
      hasher .combine (ObjectIdentifier (self) .hashValue)
   }
}
