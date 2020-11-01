//
//  X3DDamperNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public class X3DDamperNode :
   X3DFollowerNode
{
   // Fields

   @SFInt32 public final var order     : Int32 = 3
   @SFTime  public final var tau       : TimeInterval = 0.3
   @SFFloat public final var tolerance : Float = -1

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DDamperNode)
   }
}
