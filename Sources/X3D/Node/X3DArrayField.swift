//
//  X3DArrayField.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DArrayField :
   X3DField
{
   public final var isEmpty : Bool { count == 0 }
   
   public var count : Int { 0 }
   
   public final override var isDefaultValue : Bool { count == 0 }
}
