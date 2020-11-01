//
//  X3DCylinderOptions.swift
//  X3D
//
//  Created by Holger Seelig on 09.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DCylinderOptions :
   X3DBaseNode
{
   // Fields
   
   @SFInt32 internal final var uDimension : Int32 = 20
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addField (.inputOutput, "uDimension", $uDimension)
   }
}
