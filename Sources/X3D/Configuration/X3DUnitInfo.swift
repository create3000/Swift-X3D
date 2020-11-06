//
//  X3DUnitInfo.swift
//  X3D
//
//  Created by Holger Seelig on 21.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DUnitInfo :
   X3DObject
{
   // Common properties
   
   public final override class var typeName : String { "X3DUnitInfo" }
   
   // Properties
   
   public final let category         : X3DUnitCategory
   public final let name             : String
   public final let conversionFactor : Double
   
   // Construction
   
   internal init (category : X3DUnitCategory, name : String, conversionFactor : Double)
   {
      self .category         = category
      self .name             = name
      self .conversionFactor = conversionFactor
      
      super .init ()
   }
}
