//
//  X3DGeospatialObject.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public protocol X3DGeospatialObject :
   X3DNode
{
   // Fields

   //@MFString public final var geoSystem : [String] = ["GD", "WE"]
   //@SFNode   public final var geoOrigin : X3DNode?

   var geoSystem : [String] { get }
   var geoOrigin : X3DNode? { get set }
}

extension X3DGeospatialObject
{
   // Construction
   
   internal func initGeospatialObject ()
   {
      types .append (.X3DGeospatialObject)
   }
}
