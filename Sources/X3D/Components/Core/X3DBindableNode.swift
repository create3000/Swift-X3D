//
//  X3DBindableNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public class X3DBindableNode :
   X3DChildNode
{
   // Fields

   @SFBool public final var set_bind : Bool = false
   @SFBool public final var isBound  : Bool = false
   @SFTime public final var bindTime : TimeInterval = 0

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DBindableNode)
      
      setCameraObject (true)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      $set_bind .addInterest ("set_bind_", X3DBindableNode .set_bind_, self)
   }
   
   // Event handlers
   
   internal var updateTime : TimeInterval = 0
   
   internal func set_bind_ ()
   {
      guard set_bind != isBound else { return }
      
      updateTime = SFTime .now ()
   }
   
   // Operations
   
   internal func transitionStart (with layer : X3DLayerNode, from node : X3DBindableNode) { }
   internal func transitionStop () { }
}
