//
//  X3DSensorNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public protocol X3DSensorNode :
   X3DChildNode
{
   // Fields

   //@SFBool public final var enabled  : Bool = true
   //@SFBool public final var isActive : Bool = false

   var enabled  : Bool { get set }
   var isActive : Bool { get set }
}

extension X3DSensorNode
{
   // Construction
   
   internal func initSensorNode ()
   {
      types .append (.X3DSensorNode)
   }
}
