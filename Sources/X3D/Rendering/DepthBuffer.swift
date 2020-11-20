//
//  File.swift
//  
//
//  Created by Holger Seelig on 20.11.20.
//

import Metal

internal class DepthBuffer
{
   internal final let width        : Int
   internal final let height       : Int
   internal final let colorTexture : MTLTexture
   internal final let depthTexture : MTLTexture
   internal final let depthBuffer  : MTLBuffer
 
   internal init (_ browser : X3DBrowser, width : Int, height : Int)
   {
      self .width  = width
      self .height = height
      
      // Color texture
      
      do
      {
         let textureDescriptor = MTLTextureDescriptor ()
         
         textureDescriptor .textureType = MTLTextureType .type2D
         textureDescriptor .width       = width
         textureDescriptor .height      = height
         textureDescriptor .pixelFormat = .bgra8Unorm
         textureDescriptor .storageMode = .managed
         textureDescriptor .usage       = [.renderTarget, .shaderRead, .shaderWrite]

         colorTexture = browser .device! .makeTexture (descriptor: textureDescriptor)!
      }

      // Depth texture
      
      do
      {
         let textureDescriptor = MTLTextureDescriptor ()
         
         textureDescriptor .textureType = MTLTextureType .type2D
         textureDescriptor .width       = width
         textureDescriptor .height      = height
         textureDescriptor .pixelFormat = .depth32Float
         textureDescriptor .storageMode = .private
         textureDescriptor .usage       = [.renderTarget, .shaderRead, .shaderWrite]

         depthTexture = browser .device! .makeTexture (descriptor: textureDescriptor)!
      }

      // Depth buffer
      
      depthBuffer = browser .device! .makeBuffer (length: 4 * width * height, options: [ ])!
   }
   
   internal final func blit (_ commandBuffer : MTLCommandBuffer)
   {
      // Now add a blit to the CPU-accessible buffer
      let blitter = commandBuffer .makeBlitCommandEncoder ()!
      
      blitter .copy (from: depthTexture,
                     sourceSlice: 0,
                     sourceLevel: 0,
                     sourceOrigin: MTLOriginMake (0, 0, 0),
                     sourceSize: MTLSizeMake (width, height, 1),
                     to: depthBuffer,
                     destinationOffset: 0,
                     destinationBytesPerRow: 4 * width,
                     destinationBytesPerImage: 4 * width * height)
      
      blitter .endEncoding ()
   }
   
   internal final func depth (_ projectionMatrix : Matrix4f) -> Float
   {
      let contents = depthBuffer .contents () .bindMemory (to: Float32 .self, capacity: 1)
      let pointer  = UnsafeBufferPointer <Float> (start: contents, count: width * height)
      let array    = ContiguousArray <Float> (pointer)
      let winz     = array .min ()!
            
      let point = ViewVolume .unProjectPoint (Float (width / 2),
                                              Float (height / 2),
                                              winz,
                                              projectionMatrix .inverse,
                                              Vector4i (0, 0, Int32 (width), Int32 (height)))

      return point .z
   }
}
