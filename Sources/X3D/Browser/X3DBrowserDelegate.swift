//
//  X3DRenderer.swift
//  Sunrise X3D Editor
//
//  Created by Holger Seelig on 18.08.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal
import MetalKit

class X3DBrowserDelegate :
   NSObject,
   MTKViewDelegate
{
   // Properties
   
   private unowned let surface : X3DBrowserSurface
   private let commandQueue : MTLCommandQueue
   
   // Construction
   
   internal init (surface mtkview : X3DBrowserSurface)
   {
      surface      = mtkview
      commandQueue = mtkview .device! .makeCommandQueue ()!
   }
   
   // Rendering

   public final func mtkView (_ mtkview : MTKView, drawableSizeWillChange size : CGSize)
   {
      //debugPrint (size, surface .drawableSize, surface .layer! .contentsScale, surface .bounds)
   }

   public final func draw (in mtkview : MTKView)
   {
      guard let commandBuffer = commandQueue .makeCommandBuffer () else { return }
      
      // Clear surface.
      
      guard let renderPassDescriptor = mtkview .currentRenderPassDescriptor else { return }
      
      renderPassDescriptor .colorAttachments [0] .loadAction = .clear
      renderPassDescriptor .colorAttachments [0] .clearColor = MTLClearColor (red: 0, green: 0, blue: 0, alpha: 0)
       
      guard let renderEncoder = commandBuffer .makeRenderCommandEncoder (descriptor: renderPassDescriptor) else { return }
       
      renderEncoder .endEncoding ()
      
      // Update surface.

      surface .update (commandBuffer)

      commandBuffer .present (mtkview .currentDrawable!)
      commandBuffer .commit ()
   }
}
