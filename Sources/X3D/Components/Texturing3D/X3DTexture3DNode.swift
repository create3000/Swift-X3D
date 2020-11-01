//
//  X3DTexture3DNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DTexture3DNode :
   X3DTextureNode
{
   // Fields

   @SFBool public final var repeatS           : Bool = false
   @SFBool public final var repeatT           : Bool = false
   @SFBool public final var repeatR           : Bool = false
   @SFNode public final var textureProperties : X3DNode?

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DTexture3DNode)
   }
}
