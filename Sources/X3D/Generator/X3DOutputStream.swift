//
//  X3DOutputStream.swift
//  X3D
//
//  Created by Holger Seelig on 04.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DOutputStream
{
   // String handling
   
   internal private(set) final var string : String = ""
   
   @inlinable
   internal static func += (stream : X3DOutputStream, string : String)
   {
      stream .string += string
   }
   
   internal private(set) final var indent : String = ""
   
   // Execution context handling
   
   @inlinable
   internal var executionContext : X3DExecutionContext { executionContexts .last! }

   private var executionContexts = [X3DExecutionContext] ()
   
   @inlinable
   internal final func push (_ executionContext : X3DExecutionContext)
   {
      executionContexts .append (executionContext)
   }
   
   @inlinable
   internal final func pop (_ executionContext : X3DExecutionContext)
   {
      executionContexts .removeLast ()
   }
   
   // Scope handling
   
   internal final func enterScope ()
   {
      
   }
   
   internal final func leaveScope ()
   {
      
   }
}
