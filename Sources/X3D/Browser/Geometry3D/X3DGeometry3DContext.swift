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
   
   fileprivate private(set) var coneOptions     : X3DConeOptions
   fileprivate private(set) var cylinderOptions : X3DCylinderOptions
   fileprivate private(set) var sphereOptions   : X3DSphereOptions

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      self .coneOptions     = X3DConeOptions       (with: executionContext)
      self .cylinderOptions = X3DCylinderOptions   (with: executionContext)
      self .sphereOptions   = X3DQuadSphereOptions (with: executionContext)
 
      super .init (executionContext .browser!, executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      coneOptions     .setup ()
      cylinderOptions .setup ()
      sphereOptions   .setup ()
      
      browser! .browserOptions .$PrimitiveQuality .addInterest ("set_primitiveQuality", { $0 .set_primitiveQuality () }, self)
   }
   
   private final func set_primitiveQuality ()
   {
      switch browser! .browserOptions .PrimitiveQuality
      {
         case "LOW": do
         {
            coneOptions     .uDimension = 16
            cylinderOptions .uDimension = 16
            
            if let sphereOptions = sphereOptions as? X3DQuadSphereOptions
            {
               sphereOptions .uDimension = 20
               sphereOptions .vDimension = 9
            }
         }
         case "HIGH": do
         {
            coneOptions     .uDimension = 32
            cylinderOptions .uDimension = 32
            
            if let sphereOptions = sphereOptions as? X3DQuadSphereOptions
            {
               sphereOptions .uDimension = 64
               sphereOptions .vDimension = 31
            }
         }
         default: do
         {
            coneOptions     .uDimension = 20
            cylinderOptions .uDimension = 20
            
            if let sphereOptions = sphereOptions as? X3DQuadSphereOptions
            {
               sphereOptions .uDimension = 32
               sphereOptions .vDimension = 15
            }
         }
      }
   }
}

internal protocol X3DGeometry3DContext : AnyObject
{
   var browser                     : X3DBrowser { get }
   var geometry3DContextProperties : X3DGeometry3DContextProperties! { get }
}

extension X3DGeometry3DContext
{
   internal var coneOptions     : X3DConeOptions { geometry3DContextProperties .coneOptions }
   internal var cylinderOptions : X3DCylinderOptions { geometry3DContextProperties .cylinderOptions }
   internal var sphereOptions   : X3DSphereOptions { geometry3DContextProperties .sphereOptions }
}
