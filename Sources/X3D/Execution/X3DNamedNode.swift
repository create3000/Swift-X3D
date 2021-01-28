//
//  X3DNamedNode.swift
//  X3D
//
//  Created by Holger Seelig on 18.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DNamedNode
{
   public private(set) final weak var executionContext : X3DExecutionContext?
   public private(set) final weak var node             : X3DNode?
   public final let name                               : String

   internal init (_ executionContext : X3DExecutionContext, _ node : X3DNode, _ name : String)
   {
      self .executionContext = executionContext
      self .node             = node
      self .name             = name
      
      node .deleted .addInterest ("deleted", { $0 .set_node () }, self)
   }
   
   private final func set_node ()
   {
      executionContext? .removeNamedNode (name: name)
   }
}
