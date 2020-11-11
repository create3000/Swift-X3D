//
//  X3DPointingDeviceSensorNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DPointingDeviceSensorNode :
   X3DChildNode,
   X3DSensorNode
{
   // Fields

   @SFBool   public final var enabled     : Bool = true
   @SFString public final var description : String = ""
   @SFBool   public final var isActive    : Bool = false
   @SFBool   public final var isOver      : Bool = false
   
   // Properties
   
   internal final var viewport         : Vector4i = .zero
   internal final var projectionMatrix : Matrix4f = .identity
   internal final var modelViewMatrix  : Matrix4f = .identity

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)
      
      initSensorNode ()

      types .append (.X3DPointingDeviceSensorNode)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $enabled .addInterest (X3DPointingDeviceSensorNode .set_enabled, self)
   }
   
   // Event handlers
   
   internal final func set_enabled ()
   {
      guard !enabled else { return }

      if isActive { isActive = false }

      if isOver { isOver = false }
   }
   
   internal func set_over (over : Bool,
                           hit : Hit,
                           modelViewMatrix : Matrix4f,
                           projectionMatrix : Matrix4f,
                           viewport : Vector4i)
   { }
   
   internal func set_active (active : Bool,
                             hit : Hit,
                             modelViewMatrix : Matrix4f,
                             projectionMatrix : Matrix4f,
                             viewport : Vector4i)
   { }
   
   internal func set_motion (hit : Hit)
   { }
   
   // Traverse
   
   internal final func push (renderer : X3DRenderer, sensors : inout Set <PointingDeviceSensorContainer>)
   {
      guard enabled else { return }
      
      sensors .insert (PointingDeviceSensorContainer (pointingDeviceSensorNode: self,
                                                      modelViewMatrix: renderer .modelViewMatrix .top,
                                                      projectionMatrix: renderer .projectionMatrix .top,
                                                      viewport: renderer .viewport .last!))
   }
}
