//
//  X3DRenderingContext.swift
//  X3D
//
//  Created by Holger Seelig on 03.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

internal enum X3DRenderPipelineState
{
   case PointOpaque
   case PointTransparent
   case LineOpaque
   case LineTransparent
   case GouraudOpaque
   case GouraudTransparent
   case PhongOpaque
   case PhongTransparent
}

internal final class X3DRenderingContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate final var renderers                  : [X3DRenderer] = [ ]
   fileprivate final var depthStencilState          : [Bool : MTLDepthStencilState] = [:]
   fileprivate final var renderPipelineState        : [X3DRenderPipelineState : MTLRenderPipelineState] = [:]
   fileprivate final var defaultRenderPipelineState : [Bool : MTLRenderPipelineState] = [:]
   fileprivate final var defaultSampler             : MTLSamplerState?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      depthStencilState [false] = buildDepthStencilState (depth: false)
      depthStencilState [true]  = buildDepthStencilState (depth: true)

      renderPipelineState [.PointOpaque]        = buildRenderPipelineState (shader: "point",   blending: false)
      renderPipelineState [.PointTransparent]   = buildRenderPipelineState (shader: "point",   blending: true)
      renderPipelineState [.LineOpaque]         = buildRenderPipelineState (shader: "line",    blending: false)
      renderPipelineState [.LineTransparent]    = buildRenderPipelineState (shader: "line",    blending: true)
      renderPipelineState [.GouraudOpaque]      = buildRenderPipelineState (shader: "gouraud", blending: false)
      renderPipelineState [.GouraudTransparent] = buildRenderPipelineState (shader: "gouraud", blending: true)
      renderPipelineState [.PhongOpaque]        = buildRenderPipelineState (shader: "phong",   blending: false)
      renderPipelineState [.PhongTransparent]   = buildRenderPipelineState (shader: "phong",   blending: true)
      
      defaultRenderPipelineState [false] = renderPipelineState [.GouraudOpaque]
      defaultRenderPipelineState [true]  = renderPipelineState [.GouraudTransparent]

      defaultSampler = buildDefaultSampler ()
   }
   
   private final func buildRenderPipelineState (shader : String, blending : Bool) -> MTLRenderPipelineState
   {
      // Create a new pipeline descriptor.
      let pipelineDescriptor = MTLRenderPipelineDescriptor ()
      
      // Setup the shaders in the pipeline.
      let library = try! browser! .device! .makeDefaultLibrary (bundle: Bundle .module)
      
      pipelineDescriptor .vertexFunction   = library .makeFunction (name: shader + "VertexShader")
      pipelineDescriptor .fragmentFunction = library .makeFunction (name: shader + "FragmentShader")
      
      // Setup the output pixel format to match the pixel format of the metal kit view.
      pipelineDescriptor .colorAttachments [0] .pixelFormat                 = browser! .colorPixelFormat
      pipelineDescriptor .colorAttachments [0] .isBlendingEnabled           = blending
      pipelineDescriptor .colorAttachments [0] .sourceRGBBlendFactor        = .sourceAlpha
      pipelineDescriptor .colorAttachments [0] .sourceAlphaBlendFactor      = .one
      pipelineDescriptor .colorAttachments [0] .destinationRGBBlendFactor   = .oneMinusSourceAlpha
      pipelineDescriptor .colorAttachments [0] .destinationAlphaBlendFactor = .oneMinusSourceAlpha
      pipelineDescriptor .colorAttachments [0] .alphaBlendOperation         = .add
      pipelineDescriptor .colorAttachments [0] .rgbBlendOperation           = .add
      
      // Setup the output pixel format to match the pixel format of the metal kit view.
      pipelineDescriptor .depthAttachmentPixelFormat = browser! .depthStencilPixelFormat
      
      // Compile the configured pipeline descriptor to a pipeline state object.
      return try! browser! .device! .makeRenderPipelineState (descriptor: pipelineDescriptor)
   }
   
   private final func buildDepthStencilState (depth : Bool) -> MTLDepthStencilState
   {
      let depthStencilDescriptor = MTLDepthStencilDescriptor ()
      
      depthStencilDescriptor .depthCompareFunction = .lessEqual
      depthStencilDescriptor .isDepthWriteEnabled  = depth
      
      return browser! .device! .makeDepthStencilState (descriptor: depthStencilDescriptor)!
   }
   
   internal final func buildDefaultSampler () -> MTLSamplerState?
   {
      let sampler = MTLSamplerDescriptor ()
      
      sampler .minFilter             = MTLSamplerMinMagFilter .nearest
      sampler .magFilter             = MTLSamplerMinMagFilter .nearest
      sampler .mipFilter             = MTLSamplerMipFilter .nearest
      sampler .maxAnisotropy         = 1
      sampler .sAddressMode          = MTLSamplerAddressMode .repeat
      sampler .tAddressMode          = MTLSamplerAddressMode .repeat
      sampler .rAddressMode          = MTLSamplerAddressMode .repeat
      sampler .normalizedCoordinates = true
      sampler .lodMinClamp           = 0
      sampler .lodMaxClamp           = .greatestFiniteMagnitude
      
      return browser! .device! .makeSamplerState (descriptor: sampler)!
   }
}

internal protocol X3DRenderingContext : class
{
   var browser                    : X3DBrowser { get }
   var renderingContextProperties : X3DRenderingContextProperties! { get }
}

extension X3DRenderingContext
{
   internal func popRenderer () -> X3DRenderer
   {
      if renderingContextProperties .renderers .isEmpty
      {
         return X3DRenderer (for: browser)
      }
      else
      {
         return renderingContextProperties .renderers .removeLast ()
      }
   }
   
   internal func pushRenderer (_ renderer : X3DRenderer)
   {
      renderingContextProperties .renderers .append (renderer)
   }
   
   internal var viewport : Vector4i { Vector4i (0, 0, Int32 (browser .drawableSize .width), Int32 (browser .drawableSize .height)) }
   
   internal var depthStencilState          : [Bool : MTLDepthStencilState] { renderingContextProperties .depthStencilState }
   internal var renderPipelineState        : [X3DRenderPipelineState : MTLRenderPipelineState] { renderingContextProperties .renderPipelineState }
   internal var defaultRenderPipelineState : [Bool : MTLRenderPipelineState] { renderingContextProperties .defaultRenderPipelineState }
   internal var defaultSampler             : MTLSamplerState { renderingContextProperties .defaultSampler! }
}
