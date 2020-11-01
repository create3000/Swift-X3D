//
//  X3DColorNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DColorNode :
   X3DGeometricPropertyNode
{
   // Properties
   
   @SFBool internal final var isTransparent : Bool = false

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DColorNode)
      
      addChildObjects ($isTransparent)
   }
   
   // Transparent handling
   
   internal final func setTransparent (_ value : Bool)
   {
      guard value != isTransparent else { return }
      
      isTransparent = value
   }
   
   // Member access
   
   internal func get1Color (at index : Int) -> Color4f
   {
      return Vector4f .one
   }
}
