//
//  X3DMatrixStack.swift
//  X3D
//
//  Created by Holger Seelig on 15.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import simd

public final class X3DMatrixStack
{
   // Member types
   
   public typealias Matrix = Matrix4f
   
   // Properties
   
   private final var stack : [Matrix] = [ ]
   
   // Capacity
   
   public final var isEmpty : Bool { stack .isEmpty }
   public final var count : Int { stack .count }
   public final var top : Matrix { stack .last! }
   
   // Operations
   
   public final func push ()
   {
      stack .append (stack .last!)
   }
   
   public final func push (_ matrix : Matrix)
   {
      stack .append (matrix)
   }
   
   public final func pop ()
   {
      stack .removeLast ()
   }
   
   // Operations
   
   public final func mult (_ matrix : Matrix)
   {
      stack [stack .count - 1] *= matrix
   }
}
