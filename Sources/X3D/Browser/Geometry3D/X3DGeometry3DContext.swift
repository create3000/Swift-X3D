//
//  X3DGeometry3DContext.swift
//  X3D
//
//  Created by Holger Seelig on 08.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DGeometry3DContextProperties :
   X3DBaseNode
{
   // Properties
   
   @SFNode fileprivate private(set) var coneOptions     : X3DConeOptions?
   @SFNode fileprivate private(set) var cylinderOptions : X3DCylinderOptions?
   @SFNode fileprivate private(set) var sphereOptions   : X3DSphereOptions?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addChildObjects ($coneOptions,
                       $cylinderOptions,
                       $sphereOptions)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      coneOptions     = X3DConeOptions       (with: executionContext!)
      cylinderOptions = X3DCylinderOptions   (with: executionContext!)
      sphereOptions   = X3DQuadSphereOptions (with: executionContext!)
 
      coneOptions!     .setup ()
      cylinderOptions! .setup ()
      sphereOptions!   .setup ()
   }
}

internal protocol X3DGeometry3DContext : class
{
   var browser                     : X3DBrowser { get }
   var geometry3DContextProperties : X3DGeometry3DContextProperties! { get }
}

extension X3DGeometry3DContext
{
   internal var coneOptions     : X3DConeOptions { geometry3DContextProperties .coneOptions! }
   internal var cylinderOptions : X3DCylinderOptions { geometry3DContextProperties .cylinderOptions! }
   internal var sphereOptions   : X3DSphereOptions { geometry3DContextProperties .sphereOptions! }
}
