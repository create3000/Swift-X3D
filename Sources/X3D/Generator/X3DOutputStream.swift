//
//  X3DOutputStream.swift
//  X3D
//
//  Created by Holger Seelig on 04.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DOutputStream :
   CustomStringConvertible
{
   internal final var description: String { string }
   
   private final var string : String = ""
   
   internal static func += (stream : X3DOutputStream, string : String)
   {
      stream .string += string
   }
}
