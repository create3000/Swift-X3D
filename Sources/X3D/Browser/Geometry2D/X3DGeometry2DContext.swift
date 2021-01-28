//
//  X3DGeometry2DContext.swift
//  X3D
//
//  Created by Holger Seelig on 11.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DGeometry2DContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate private(set) var arc2DOptions      : X3DArc2DOptions
   fileprivate private(set) var arcClose2DOptions : X3DArcClose2DOptions
   fileprivate private(set) var circle2DOptions   : X3DCircle2DOptions
   fileprivate private(set) var disk2DOptions     : X3DDisk2DOptions

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      self .arc2DOptions      = X3DArc2DOptions      (with: executionContext)
      self .arcClose2DOptions = X3DArcClose2DOptions (with: executionContext)
      self .circle2DOptions   = X3DCircle2DOptions   (with: executionContext)
      self .disk2DOptions     = X3DDisk2DOptions     (with: executionContext)

      super .init (executionContext .browser!, executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      arc2DOptions      .setup ()
      arcClose2DOptions .setup ()
      circle2DOptions   .setup ()
      disk2DOptions     .setup ()
      
      browser! .browserOptions .$PrimitiveQuality .addInterest ("set_primitiveQuality", { $0 .set_primitiveQuality () }, self)
   }
   
   private final func set_primitiveQuality ()
   {
      switch browser! .browserOptions .PrimitiveQuality
      {
         case "LOW": do
         {
            arc2DOptions      .dimension = 20
            arcClose2DOptions .dimension = 20
            circle2DOptions   .dimension = 20
            disk2DOptions     .dimension = 20
         }
         case "HIGH": do
         {
            arc2DOptions      .dimension = 80
            arcClose2DOptions .dimension = 80
            circle2DOptions   .dimension = 80
            disk2DOptions     .dimension = 80
         }
         default: do
         {
            arc2DOptions      .dimension = 40
            arcClose2DOptions .dimension = 40
            circle2DOptions   .dimension = 40
            disk2DOptions     .dimension = 40
         }
      }
   }
}

internal protocol X3DGeometry2DContext : class
{
   var browser                     : X3DBrowser { get }
   var geometry2DContextProperties : X3DGeometry2DContextProperties! { get }
}

extension X3DGeometry2DContext
{
   internal var arc2DOptions      : X3DArc2DOptions { geometry2DContextProperties .arc2DOptions }
   internal var arcClose2DOptions : X3DArcClose2DOptions { geometry2DContextProperties .arcClose2DOptions }
   internal var circle2DOptions   : X3DCircle2DOptions { geometry2DContextProperties .circle2DOptions }
   internal var disk2DOptions     : X3DDisk2DOptions { geometry2DContextProperties .disk2DOptions }
}
