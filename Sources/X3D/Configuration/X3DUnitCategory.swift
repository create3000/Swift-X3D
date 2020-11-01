//
//  UnitCategory.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public enum X3DUnitCategory
{
   case unitless

   // Standard units

   case angle
   case force
   case length
   case mass

   // Derived units

   case acceleration
   case angular_rate
   case area
   case speed
   case volume

   private static let units : [String : X3DUnitCategory] = [
      "angle"  : .angle,
      "force"  : .force,
      "length" : .length,
      "mass"   : .mass,
   ]
   
   init? (_ string : String)
   {
      guard let value = X3DUnitCategory .units [string] else { return nil }
      
      self = value
   }
}
