//
//  X3DArc2DOptions.swift
//  X3D
//
//  Created by Holger Seelig on 12.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DArc2DOptions :
   X3DBaseNode
{
   // Fields
   
   @SFInt32 internal final var dimension : Int32 = 32
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addField (.inputOutput, "dimension", $dimension)
   }
}
