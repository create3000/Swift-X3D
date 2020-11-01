//
//  X3DPickableObject.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public protocol X3DPickableObject :
   X3DBaseNode
{
   // Fields

   //@SFBool   public final var pickable   : Bool = true
   //@MFString public final var objectType : MFString .Value = ["ALL"]
   
   var pickable   : Bool { get set }
   var objectType : MFString .Value { get }
}

extension X3DPickableObject
{
   // Construction
   
   internal func initPickableObject ()
   {
      types .append (.X3DPickableObject)
   }
}
