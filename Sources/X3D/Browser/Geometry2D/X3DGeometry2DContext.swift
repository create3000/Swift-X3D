//
//  X3DGeometry2DContext.swift
//  X3D
//
//  Created by Holger Seelig on 11.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DGeometry2DContextProperties :
   X3DBaseNode
{
   // Properties
   
   @SFNode fileprivate private(set) var arc2DOptions      : X3DArc2DOptions?
   @SFNode fileprivate private(set) var arcClose2DOptions : X3DArcClose2DOptions?
   @SFNode fileprivate private(set) var circle2DOptions   : X3DCircle2DOptions?
   @SFNode fileprivate private(set) var disk2DOptions     : X3DDisk2DOptions?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addChildObjects ($arc2DOptions,
                       $arcClose2DOptions,
                       $circle2DOptions,
                       $disk2DOptions)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      arc2DOptions      = X3DArc2DOptions      (with: executionContext!)
      arcClose2DOptions = X3DArcClose2DOptions (with: executionContext!)
      circle2DOptions   = X3DCircle2DOptions   (with: executionContext!)
      disk2DOptions     = X3DDisk2DOptions     (with: executionContext!)

      arc2DOptions!      .setup ()
      arcClose2DOptions! .setup ()
      circle2DOptions!   .setup ()
      disk2DOptions!     .setup ()
   }
}

public protocol X3DGeometry2DContext : class
{
   var browser                     : X3DBrowser { get }
   var geometry2DContextProperties : X3DGeometry2DContextProperties! { get }
}

extension X3DGeometry2DContext
{
   internal var arc2DOptions      : X3DArc2DOptions { geometry2DContextProperties .arc2DOptions! }
   internal var arcClose2DOptions : X3DArcClose2DOptions { geometry2DContextProperties .arcClose2DOptions! }
   internal var circle2DOptions   : X3DCircle2DOptions { geometry2DContextProperties .circle2DOptions! }
   internal var disk2DOptions     : X3DDisk2DOptions { geometry2DContextProperties .disk2DOptions! }
}
