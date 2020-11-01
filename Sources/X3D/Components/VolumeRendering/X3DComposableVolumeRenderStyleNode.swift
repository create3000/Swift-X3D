//
//  X3DComposableVolumeRenderStyleNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DComposableVolumeRenderStyleNode :
   X3DVolumeRenderStyleNode
{
   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DComposableVolumeRenderStyleNode)
   }
}
