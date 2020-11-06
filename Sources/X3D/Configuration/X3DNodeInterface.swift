//
//  X3DNodeInterface.swift
//  X3D
//
//  Created by Holger Seelig on 18.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal protocol X3DNodeInterface :
   X3DNode
{
   /// Creates a new fresh instance of this node.
   /// * parameters:
   ///   * executionContext: The execution context this node should belong to.
   init (with executionContext : X3DExecutionContext)
}
