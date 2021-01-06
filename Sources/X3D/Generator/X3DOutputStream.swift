//
//  X3DOutputStream.swift
//  X3D
//
//  Created by Holger Seelig on 04.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DOutputStream
{
   internal private(set) final var string : String = ""
   
   internal static func += (stream : X3DOutputStream, string : String)
   {
      stream .string += string
   }
   
   internal var executionContexts = [X3DExecutionContext] ()
   
   internal var executionContext : X3DExecutionContext { executionContexts .last! }
}
