//
//  X3DShaderNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public class X3DShaderNode :
   X3DAppearanceChildNode
{
   // Fields

   @SFBool   public final var activate   : Bool = false
   @SFBool   public final var isSelected : Bool = false
   @SFBool   public final var isValid    : Bool = false
   @SFString public final var language   : String = ""
   
   // Properties
   
   @SFTime internal final var activationTime : TimeInterval = 0

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DShaderNode)
      
      addChildObjects ($activationTime)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      $activate .addInterest ("set_activate", { $0 .set_activate () }, self)
   }
   
   // Event handlers
   
   private final func set_activate ()
   {
      activationTime = browser! .currentTime
   }
   
   // Operations
   
   private final var selections = 0
   
   internal final func select ()
   {
      selections += 1
      
      if !isSelected { isSelected = true }
   }
   
   internal final func deselect ()
   {
      selections -= 1
      
      if selections == 0 { isSelected = false }
   }

   internal func enable (_ renderEncoder : MTLRenderCommandEncoder, blending : Bool) { }
}
