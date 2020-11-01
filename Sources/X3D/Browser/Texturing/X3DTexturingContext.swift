//
//  X3DTexturingContext.swift
//  X3D
//
//  Created by Holger Seelig on 14.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal
import MetalKit
import SwiftImage

public final class X3DTexturingContextProperies :
   X3DBaseNode
{
   // Properties
   
   fileprivate private(set) var defaultTexture : MTLTexture?
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      let swifty2D      = Image <RGBA <UInt8>> (width: 1, height: 1, pixels: [RGBA <UInt8> .white])
      let textureLoader = MTKTextureLoader (device: browser! .device!)
      
      defaultTexture = try! textureLoader .newTexture (cgImage: swifty2D .cgImage)
   }
}

public protocol X3DTexturingContext : class
{
   var browser                    : X3DBrowser { get }
   var texturingContextProperties : X3DTexturingContextProperies! { get }
}

extension X3DTexturingContext
{
   internal var minTextureSize : Int { 16 }
   internal var defaultTexture : MTLTexture { texturingContextProperties .defaultTexture! }
}
