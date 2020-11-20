//
//  File.swift
//  
//
//  Created by Holger Seelig on 19.11.20.
//

import Metal

internal final class CollisionContext
{
   internal final unowned var browser    : X3DBrowser!
   internal final unowned var renderer   : Renderer
   internal final unowned var shapeNode  : X3DShapeNode!
   internal final var collisions         : [Collision] = [ ]
   internal final let uniformsBuffer     : MTLBuffer
   internal final let uniforms           : UnsafeMutablePointer <x3d_Uniforms>

   internal init (renderer : Renderer)
   {
      self .browser  = renderer .browser
      self .renderer = renderer
      
      // Init uniforms.
      
      let device          = browser .device!
      var initialUniforms = x3d_Uniforms ()
      
      self .uniformsBuffer = device .makeBuffer (bytes: &initialUniforms,
                                                 length: MemoryLayout <x3d_Uniforms> .stride,
                                                 options: [])!
      
      self .uniforms = uniformsBuffer .contents () .bindMemory (to: x3d_Uniforms .self, capacity: 1)
   }
}
