//
//  X3DNamedNode.swift
//  X3D
//
//  Created by Holger Seelig on 18.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal class X3DNamedNode :
   X3DInputOutput
{
   internal private(set) final weak var executionContext : X3DExecutionContext?
   internal private(set) final weak var node             : X3DNode?
   internal final let name                               : String

   internal init (_ executionContext : X3DExecutionContext, _ node : X3DNode, _ name : String)
   {
      self .executionContext = executionContext
      self .node             = node
      self .name             = name
      
      node .deleted .addInterest ("deleted", X3DNamedNode .set_node, self)
   }
   
   private final func set_node ()
   {
      executionContext? .removeNamedNode (name: name)
   }
}
