//
//  X3DVolumeDataNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DVolumeDataNode :
   X3DChildNode,
   X3DBoundedObject
{
   // Fields

   @SFVec3f public final var dimensions : Vector3f = Vector3f (1, 1, 1)
   @SFVec3f public final var bboxSize   : Vector3f = -.one
   @SFVec3f public final var bboxCenter : Vector3f = .zero

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)
      
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)

      types .append (.X3DVolumeDataNode)
   }
   
   // Bounded object
   
   public final var bbox : Box3f { .empty }
}
