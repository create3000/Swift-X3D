//
//  X3DAppearanceNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public class X3DAppearanceNode :
   X3DNode
{
   // Properties
   
   @SFBool internal final var isTransparent : Bool = false

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DAppearanceNode)
      
      addChildObjects ($isTransparent)
   }
   
   // Member accsess
   
   internal final func setTransparent (_ value : Bool)
   {
      guard value != isTransparent else { return }
      
      isTransparent = value
   }
   
   // Rendering
   
   internal func render (_ context : X3DRenderContext, _ renderEncoder : MTLRenderCommandEncoder) { }
}
