//
//  File.swift
//  
//
//  Created by Holger Seelig on 11.11.20.
//

internal final class X3DPointingDeviceSensorContainer
{
   // Properties
   
   private final var node             : X3DPointingDeviceSensorNode
   private final var modelViewMatrix  : Matrix4f
   private final var projectionMatrix : Matrix4f
   private final var viewport         : Vector4i
   
   // Construction
   
   internal init (_ node : X3DPointingDeviceSensorNode,
                  _ modelViewMatrix : Matrix4f,
                  _ projectionMatrix : Matrix4f,
                  _ viewport : Vector4i)
   {
      self .node             = node
      self .modelViewMatrix  = modelViewMatrix
      self .projectionMatrix = projectionMatrix
      self .viewport         = viewport
   }
}

extension X3DPointingDeviceSensorContainer :
   Hashable
{
   public static func == (lhs : X3DPointingDeviceSensorContainer, rhs : X3DPointingDeviceSensorContainer) -> Bool
   {
      return lhs === rhs
   }
   
   public final func hash (into hasher: inout Hasher)
   {
      hasher .combine (ObjectIdentifier (self) .hashValue)
   }
}
