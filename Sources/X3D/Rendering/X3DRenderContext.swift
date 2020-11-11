//
//  X3DShapeContext.swift
//  X3D
//
//  Created by Holger Seelig on 18.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

internal final class X3DRenderContext
{
   internal final unowned var browser    : X3DBrowser!
   internal final unowned var renderer   : X3DRenderer
   internal final unowned var shapeNode  : X3DShapeNode!
   internal final unowned var shaderNode : X3DShaderNode?
   internal final var fogObject          : FogContainer!
   internal final var localLights        : [LightContainer] = [ ]
   internal final let isTransparent      : Bool
   internal final var distance           : Float
   internal final let uniformsBuffer     : MTLBuffer
   internal final let uniforms           : UnsafeMutablePointer <x3d_Uniforms>
   
   internal init (renderer : X3DRenderer, isTransparent : Bool)
   {
      self .browser       = renderer .browser
      self .renderer      = renderer
      self .isTransparent = isTransparent
      self .distance      = 0
      
      // Init uniforms.
      
      let device          = browser .device!
      var initialUniforms = x3d_Uniforms ()
      
      self .uniformsBuffer = device .makeBuffer (bytes: &initialUniforms,
                                                 length: MemoryLayout <x3d_Uniforms> .stride,
                                                 options: [])!
      
      self .uniforms = uniformsBuffer .contents () .bindMemory (to: x3d_Uniforms .self, capacity: 1)
   }
}
