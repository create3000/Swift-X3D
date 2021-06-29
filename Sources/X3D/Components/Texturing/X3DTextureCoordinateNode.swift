//
//  X3DTextureCoordinateNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DTextureCoordinateNode :
   X3DGeometricPropertyNode
{
   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DTextureCoordinateNode)
   }
   
   internal final func get1Point (at index: Int, array texCoords : inout [Vector4f])
   {
      texCoords .append (get1Point (at: index))
   }
   
   // Member access
   
   internal func get1Point (at : Int) -> Vector4f { Vector4f .zero }
   
   internal func setUniforms (_ uniforms : UnsafeMutablePointer <x3d_Uniforms>, to channel : Int)
   {
      switch channel
      {
         case 0: do
         {
            uniforms .pointee .textureCoordinateGenerator .0 .mode = x3d_None
         }
         case 1: do
         {
            uniforms .pointee .textureCoordinateGenerator .1 .mode = x3d_None
         }
         default:
            break
      }
   }
}
