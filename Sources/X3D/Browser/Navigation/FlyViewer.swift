//
//  File.swift
//  
//
//  Created by Holger Seelig on 17.11.20.
//

internal final class FlyViewer :
   X3DFlyViewer
{
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
}
