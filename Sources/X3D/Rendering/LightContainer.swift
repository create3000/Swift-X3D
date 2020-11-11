//
//  X3DLightContainer.swift
//  X3D
//
//  Created by Holger Seelig on 26.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class LightContainer
{
   private final unowned var lightNode : X3DLightNode
   private final var modelViewMatrix   : Matrix4f
   private final var matrix            : Matrix3f

   internal init (lightNode : X3DLightNode, modelViewMatrix : Matrix4f)
   {
      self .lightNode       = lightNode
      self .modelViewMatrix = modelViewMatrix
      self .matrix          = inverse (modelViewMatrix .submatrix)
   }
   
   internal func setUniforms (_ lightSources : X3DLightSources, _ index : Int)
   {
      guard index < x3d_MaxLights else { return }
      
      lightNode .setUniforms (lightSources .uniforms .advanced (by: index),
                              modelViewMatrix,
                              matrix)
   }
}
