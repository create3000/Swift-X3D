//
//  TouchSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TouchSensor :
   X3DTouchSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TouchSensor" }
   internal final override class var component      : String { "PointingDeviceSensor" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFVec2f public final var hitTexCoord_changed : Vector2f = .zero
   @SFVec3f public final var hitNormal_changed   : Vector3f = .zero
   @SFVec3f public final var hitPoint_changed    : Vector3f = .zero

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TouchSensor)

      addField (.inputOutput, "metadata",            $metadata)
      addField (.inputOutput, "enabled",             $enabled)
      addField (.inputOutput, "description",         $description)
      addField (.outputOnly,  "hitTexCoord_changed", $hitTexCoord_changed)
      addField (.outputOnly,  "hitNormal_changed",   $hitNormal_changed)
      addField (.outputOnly,  "hitPoint_changed",    $hitPoint_changed)
      addField (.outputOnly,  "isOver",              $isOver)
      addField (.outputOnly,  "isActive",            $isActive)
      addField (.outputOnly,  "touchTime",           $touchTime)

      $hitPoint_changed .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TouchSensor
   {
      return TouchSensor (with: executionContext)
   }
   
   // Event handlers
   
   internal final override func set_over (over : Bool,
                                          hit : Hit,
                                          modelViewMatrix : Matrix4f,
                                          projectionMatrix : Matrix4f,
                                          viewport : Vector4i)
   {
      super .set_over (over: over,
                       hit: hit,
                       modelViewMatrix: modelViewMatrix,
                       projectionMatrix: projectionMatrix,
                       viewport: viewport)
      
      guard isOver else { return }
      
      let intersection       = hit .intersection
      let invModelViewMatrix = modelViewMatrix .inverse

      hitTexCoord_changed = Vector2f (intersection .texCoord .x, intersection .texCoord .y) / intersection .texCoord .w
      hitNormal_changed   = normalize (intersection .normal * modelViewMatrix .submatrix)
      hitPoint_changed    = invModelViewMatrix * intersection .point
   }
}
