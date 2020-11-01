//
//  X3DProductStructureChildNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

//@SFString public final var name : String = ""

public protocol X3DProductStructureChildNode :
   X3DChildNode
{
   // Fields

   var name : String { get set }
}

extension X3DProductStructureChildNode
{
   // Construction
   
   internal func initProductStructureChildNode ()
   {
      types .append (.X3DProductStructureChildNode)
   }
}
