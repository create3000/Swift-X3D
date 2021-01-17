//
//  NetworkingContext.swift
//  X3D
//
//  Created by Holger Seelig on 11.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DShapeContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate private(set) var defaultAppearanceNode : Appearance
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      self .defaultAppearanceNode = Appearance (with: executionContext)

      super .init (executionContext .browser!, executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
     defaultAppearanceNode .setup ()
   }
}

internal protocol X3DShapeContext : class
{
   var browser                : X3DBrowser { get }
   var shapeContextProperties : X3DShapeContextProperties! { get }
}

extension X3DShapeContext
{
   internal var defaultAppearanceNode : Appearance { shapeContextProperties .defaultAppearanceNode }
}
