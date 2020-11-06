//
//  X3DCoordinateNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DCoordinateNode :
   X3DGeometricPropertyNode
{
   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DCoordinateNode)
   }
   
   // Member access
   
   internal var isEmpty : Bool { true }
   internal var count : Int { 0 }

   internal func get1Point (at index : Int) -> Vector3f
   {
      return .zero
   }
   
   internal func makeNormal (index1 : Int, index2 : Int, index3 : Int) -> Vector3f
   {
      return .zero
   }
   
   internal func makeNormal (index1 : Int, index2 : Int, index3 : Int, index4 : Int) -> Vector3f
   {
      return .zero
   }
}
