//
//  X3DTextureTransformNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DTextureTransformNode :
   X3DAppearanceChildNode
{
   // Properties
   
   internal final var textureMatrix = Matrix4f .identity
   
   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DTextureTransformNode)
   }
   
   // Texture matrix handling
   
   internal func getTextureMatrix (array textureMatrices : inout [Matrix4f])
   {
      textureMatrices .append (textureMatrix)
   }
}
