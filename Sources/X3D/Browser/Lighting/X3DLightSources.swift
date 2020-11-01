//
//  X3DLightSet.swift
//  X3D
//
//  Created by Holger Seelig on 26.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

internal final class X3DLightSources
{
   internal final let uniformsBuffer : MTLBuffer
   internal final let uniforms       : UnsafeMutablePointer <x3d_LightSourceParameters>
   
   internal init (browser : X3DBrowser)
   {
      // Init uniforms.
      
      let device          = browser .device!
      var initialUniforms = Array <x3d_LightSourceParameters> (repeating: x3d_LightSourceParameters (), count: Int (x3d_MaxLights))
      
      self .uniformsBuffer = device .makeBuffer (bytes: &initialUniforms,
                                                 length: MemoryLayout <x3d_LightSourceParameters> .stride,
                                                 options: [])!
      
      self .uniforms = uniformsBuffer .contents () .bindMemory (to: x3d_LightSourceParameters .self, capacity: Int (x3d_MaxLights))
   }
}
