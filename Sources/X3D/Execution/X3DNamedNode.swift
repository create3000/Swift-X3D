//
//  X3DNamedNode.swift
//  X3D
//
//  Created by Holger Seelig on 18.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal class X3DNamedNode
{
   internal final weak var node : X3DNode?
   
   internal init (_ node : X3DNode)
   {
      self .node = node
   }
}
