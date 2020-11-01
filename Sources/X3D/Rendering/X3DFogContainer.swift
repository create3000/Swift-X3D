//
//  X3DFogContainer.swift
//  X3D
//
//  Created by Holger Seelig on 27.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DFogContainer
{
   private final unowned var fogObject : X3DFogObject
   private final var matrix            : Matrix3f

   internal init (fogObject : X3DFogObject, modelViewMatrix : Matrix4f)
   {
      self .fogObject = fogObject
      self .matrix    = inverse (modelViewMatrix .submatrix)
   }
   
   internal func setUniforms (_ uniforms : UnsafeMutablePointer <x3d_Uniforms>)
   {
      fogObject .setUniforms (uniforms, matrix)
   }
}
