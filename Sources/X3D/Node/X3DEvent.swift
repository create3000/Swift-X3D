//
//  X3DEvent.swift
//  X3D
//
//  Created by Holger Seelig on 13.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DEvent
{
   internal final var field   : X3DField
   internal final var sources : Set <X3DField>
   
   public init (_ field : X3DField, _ sources : Set <X3DField> = [ ])
   {
      self .field   = field
      self .sources = sources
   }
   
   internal final func copy () -> X3DEvent
   {
      return X3DEvent (field, sources)
   }
}
