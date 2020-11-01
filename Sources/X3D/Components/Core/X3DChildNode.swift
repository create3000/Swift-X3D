//
//  X3DChildNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DChildNode :
   X3DNode
{
   // Events
   
   @SFBool internal final var isCameraObject   : Bool = false
   @SFBool internal final var isPickableObject : Bool = false

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DChildNode)
      
      addChildObjects ($isCameraObject,
                       $isPickableObject)
   }
   
   internal final func setCameraObject (_ value : Bool)
   {
      guard value != isCameraObject else { return }
      
      isCameraObject = value
   }
   
   internal final func setPickableObject (_ value : Bool)
   {
      guard value != isPickableObject else { return }
      
      isPickableObject = value
   }

   // Rendering

   internal func traverse (_ type : X3DTraverseType, _ renderer : X3DRenderer) { }
}
