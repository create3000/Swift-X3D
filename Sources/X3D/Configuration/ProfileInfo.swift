//
//  X3DProfileInfo.swift
//  X3D
//
//  Created by Holger Seelig on 20.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ProfileInfo :
   X3DObject
{
   // Common properties
   
   internal final override class var typeName : String { "X3DProfileInfo" }
   
   // Properties
   
   public final let name        : String
   public final let title       : String
   public final let providerUrl : String
   public final let components  : [ComponentInfo]
   
   // Construciton
   
   internal init (name : String, title : String, providerUrl : String, components : [ComponentInfo])
   {
      self .name        = name
      self .title       = title
      self .providerUrl = providerUrl
      self .components  = components
      
      super .init ()
   }
   
   // Input/Output
   
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      stream += "PROFILE"
      stream += stream .Space
      stream += name
   }
}
