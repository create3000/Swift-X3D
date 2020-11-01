//
//  X3DNormalNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DNormalNode :
   X3DGeometricPropertyNode
{
   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DNormalNode)
   }
   
   // Member access
   
   internal var isEmpty : Bool { true }
   internal var count : Int { 0 }
   
   internal func get1Vector (at index : Int) -> Vector3f
   {
      return Vector3f .zero
   }
}
