//
//  X3DComponentInfo.swift
//  X3D
//
//  Created by Holger Seelig on 20.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DComponentInfo :
   X3DObject
{
   // Common properties
   
   internal final override class var typeName : String { "X3DComponentInfo" }
   
   // Properties
   
   public final let title       : String
   public final let name        : String
   public final let level       : Int32
   public final let providerUrl : String
   
   // Construction
   
   internal init (title : String, name : String,  level : Int32, providerUrl : String)
   {
      self .title       = title
      self .name        = name
      self .level       = level
      self .providerUrl = providerUrl
      
      super .init ()
   }
}
