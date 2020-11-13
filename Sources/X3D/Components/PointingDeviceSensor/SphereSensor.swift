//
//  SphereSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class SphereSensor :
   X3DDragSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "SphereSensor" }
   internal final override class var component      : String { "PointingDeviceSensor" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFRotation public final var offset           : Rotation4f = Rotation4f (0, 1, 0, 0)
   @SFRotation public final var rotation_changed : Rotation4f = .identity

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.SphereSensor)

      addField (.inputOutput, "metadata",           $metadata)
      addField (.inputOutput, "enabled",            $enabled)
      addField (.inputOutput, "description",        $description)
      addField (.inputOutput, "autoOffset",         $autoOffset)
      addField (.inputOutput, "offset",             $offset)
      addField (.outputOnly,  "trackPoint_changed", $trackPoint_changed)
      addField (.outputOnly,  "rotation_changed",   $rotation_changed)
      addField (.outputOnly,  "isOver",             $isOver)
      addField (.outputOnly,  "isActive",           $isActive)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SphereSensor
   {
      return SphereSensor (with: executionContext)
   }
   
   // Event handlers

   internal final override func set_active (active : Bool,
                                            hit : Hit,
                                            modelViewMatrix : Matrix4f,
                                            projectionMatrix : Matrix4f,
                                            viewport : Vector4i)
   {
      super .set_active (active: active,
                         hit: hit,
                         modelViewMatrix: modelViewMatrix,
                         projectionMatrix: projectionMatrix,
                         viewport: viewport)
      
      if isActive
      {
         let invModelViewMatrix = modelViewMatrix .inverse
         let hitRay             = invModelViewMatrix * hit .hitRay
         let hitPoint           = invModelViewMatrix * hit .intersection .point
      }
      else
      {
         
      }
   }
   
   internal final override func set_motion (hit : Hit,
                                            modelViewMatrix : Matrix4f,
                                            projectionMatrix : Matrix4f,
                                            viewport : Vector4i)
   {
      super .set_motion (hit: hit,
                         modelViewMatrix: modelViewMatrix,
                         projectionMatrix: projectionMatrix,
                         viewport: viewport)
      
      let invModelViewMatrix = modelViewMatrix .inverse
      let hitRay             = invModelViewMatrix * hit .hitRay
   }
}
