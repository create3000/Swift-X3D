//
//  X3DChaserNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public class X3DChaserNode :
   X3DFollowerNode
{
   // Fields

   @SFTime public final var duration : TimeInterval = 1

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DChaserNode)
   }
}
