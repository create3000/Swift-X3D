//
//  X3DView.swift
//  X3D
//
//  Created by Holger Seelig on 18.08.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal
import MetalKit

public class X3DBrowserSurface :
   MTKView,
   MTKViewDelegate
{
   // Properties
   
   private var commandQueue : MTLCommandQueue!

   // Construction
   
   internal init ()
   {
      super .init (frame: CGRect (), device: nil)

      setup ()
   }
   
   public required init (coder : NSCoder)
   {
      super .init (coder: coder)
      
      setup ()
   }

   public override init (frame : CGRect, device : MTLDevice?)
   {
      super .init (frame: frame, device: device)
      
      setup ()
   }

   private final func setup ()
   {
      // Configure MTKView
      
      isPaused                = true
      enableSetNeedsDisplay   = true
      layer! .isOpaque        = false
      colorPixelFormat        = .bgra8Unorm
      depthStencilPixelFormat = .depth32Float
      device                  = device ?? X3DBrowserSurface .defaultDevice
      delegate                = self
      commandQueue            = device! .makeCommandQueue ()

      initialize ()
   }
   
   internal func initialize () { }
   
   private static let defaultDevice = MTLCreateSystemDefaultDevice ()
   
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

      update (commandBuffer)

      commandBuffer .present (mtkview .currentDrawable!)
      commandBuffer .commit ()
   }

   internal func update (_ commandBuffer : MTLCommandBuffer) { }
}
