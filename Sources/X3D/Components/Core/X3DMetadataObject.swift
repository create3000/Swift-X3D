//
//  X3DMetadataObject.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public protocol X3DMetadataObject :
   X3DNode
{
   // Fields

   //@SFString public final var name      : String = ""
   //@SFString public final var reference : String = ""

   var name      : String { get set }
   var reference : String { get set }
}

extension X3DMetadataObject
{
   internal func initMetadataObject ()
   {
      types .append (.X3DMetadataObject)
   }
}
