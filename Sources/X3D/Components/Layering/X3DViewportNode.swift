//
//  X3DViewportNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DViewportNode :
   X3DGroupingNode
{
   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DViewportNode)
   }
   
   internal func makeRectangle (with browser : X3DBrowser) -> Vector4i { browser .viewport }
   
   // Rendering
   
   internal final override func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      renderer .viewport .append (makeRectangle (with: renderer .browser))
      
      super .traverse (type, renderer)
      
      renderer .viewport .removeLast ()
   }
}
