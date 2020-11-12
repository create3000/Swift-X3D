//
//  File.swift
//  
//
//  Created by Holger Seelig on 11.11.20.
//

internal final class Hit
{
   internal final var layerNode    : X3DLayerNode?
   internal final var layerNumber  : Int
   internal final var shapeNode    : X3DShapeNode?
   internal final var pointer      : Vector2f
   internal final var hitRay       : Line3f
   internal final var intersection : Intersection
   internal final var sensors      : Set <PointingDeviceSensorContainer>?
   
   internal init (layerNode :    X3DLayerNode?,
                  layerNumber :  Int,
                  shapeNode :    X3DShapeNode?,
                  pointer :      Vector2f,
                  hitRay :       Line3f,
                  intersection : Intersection,
                  sensors :      Set <PointingDeviceSensorContainer>?)
   {
      self .layerNode    = layerNode
      self .layerNumber  = layerNumber
      self .shapeNode    = shapeNode
      self .pointer      = pointer
      self .hitRay       = hitRay
      self .intersection = intersection
      self .sensors      = sensors
   }
}
