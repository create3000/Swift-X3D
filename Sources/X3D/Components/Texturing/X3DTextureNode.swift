//
//  X3DTextureNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public class X3DTextureNode :
   X3DAppearanceChildNode
{
   // Properties
   
   @SFBool internal final var isTransparent : Bool = false

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DTextureNode)
      
      addChildObjects ($isTransparent)
   }
   
   // Member accsess
   
   internal final func setTransparent (_ value : Bool)
   {
      guard value != isTransparent else { return }
      
      isTransparent = value
   }
   
   public var checkTextureLoadState : X3DLoadState { .COMPLETE_STATE }
   
   // Texture handling
   
   internal var numTextures : Int { 1 }
   
   internal final func setFragmentTexture (_ renderEncoder : MTLRenderCommandEncoder)
   {
      setFragmentTexture (renderEncoder, index: 0)
   }
   
   internal func setFragmentTexture (_ renderEncoder : MTLRenderCommandEncoder, index : Int) { }
}
