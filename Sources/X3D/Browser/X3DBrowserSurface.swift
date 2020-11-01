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
   MTKView
{
   // Properties
   
   private final var renderer : X3DBrowserDelegate!
   
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
   
   public final override var isOpaque : Bool { false }

   private final func setup ()
   {
      // Configure MTKView
      
      isPaused                = true
      enableSetNeedsDisplay   = true
      layer! .isOpaque        = false
      colorPixelFormat        = .bgra8Unorm
      depthStencilPixelFormat = .depth32Float

      if device == nil
      {
         device = X3DBrowserSurface .defaultDevice
      }

      // Create renderer
      renderer = X3DBrowserDelegate (surface: self)
      delegate = renderer
      
      initialize ()
   }
   
   internal func initialize () { }
   
   private static let defaultDevice = MTLCreateSystemDefaultDevice ()
   
   // Rendering

   internal func update (_ commandBuffer : MTLCommandBuffer) { }
}
