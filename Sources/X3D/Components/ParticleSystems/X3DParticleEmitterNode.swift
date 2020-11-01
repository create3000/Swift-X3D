//
//  X3DParticleEmitterNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DParticleEmitterNode :
   X3DNode
{
   // Fields

   @SFFloat public final var speed       : Float = 0
   @SFFloat public final var variation   : Float = 0.25
   @SFFloat public final var mass        : Float = 0
   @SFFloat public final var surfaceArea : Float = 0

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DParticleEmitterNode)

      $speed       .unit = .speed
      $mass        .unit = .mass
      $surfaceArea .unit = .area
   }
}
