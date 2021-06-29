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

internal final class X3DTexturingContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate private(set) var defaultTexture : MTLTexture!
   fileprivate private(set) var defaultTextureCoordinateNode : TextureCoordinate
 
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      defaultTextureCoordinateNode = TextureCoordinate (with: executionContext)
      
      super .init (executionContext .browser!, executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      let swifty2D      = Image <RGBA <UInt8>> (width: 1, height: 1, pixels: [RGBA <UInt8> .white])
      let textureLoader = MTKTextureLoader (device: browser! .device!)
      
      defaultTexture = try! textureLoader .newTexture (cgImage: swifty2D .cgImage)
      
      defaultTextureCoordinateNode .setup ()
   }
}

internal protocol X3DTexturingContext : AnyObject
{
   var browser                    : X3DBrowser { get }
   var texturingContextProperties : X3DTexturingContextProperties! { get }
}

extension X3DTexturingContext
{
   internal var minTextureSize               : Int { 16 }
   internal var defaultTexture               : MTLTexture { texturingContextProperties .defaultTexture }
   internal var defaultTextureCoordinateNode : TextureCoordinate { texturingContextProperties .defaultTextureCoordinateNode }
}
