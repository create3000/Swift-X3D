//
//  X3DRigidJointNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DRigidJointNode :
   X3DNode
{
   // Fields

   @MFString public final var forceOutput : [String] = ["NONE"]
   @SFNode   public final var body1       : X3DNode?
   @SFNode   public final var body2       : X3DNode?

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DRigidJointNode)
   }
}
