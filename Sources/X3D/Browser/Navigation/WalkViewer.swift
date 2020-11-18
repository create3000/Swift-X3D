//
//  File.swift
//  
//
//  Created by Holger Seelig on 17.11.20.
//

internal final class WalkViewer :
   X3DFlyViewer
{
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
   
   internal final override func getTranslationOffset (_ translation : Vector3f) -> Vector3f
   {
      let upVector        = activeViewpoint .upVector
      let userOrientation = activeViewpoint .userOrientation
      let orientation     = Rotation4f (from: userOrientation * .yAxis, to: upVector) * userOrientation
      let offset          = orientation * translation

      return offset
   }
}
