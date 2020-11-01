//
//  X3DProfileInfo.swift
//  X3D
//
//  Created by Holger Seelig on 20.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DProfileInfo
{
   public final let name        : String
   public final let title       : String
   public final let providerUrl : String
   public final let components  : [X3DComponentInfo]
   
   internal init (name : String, title : String, providerUrl : String, components : [X3DComponentInfo])
   {
      self .name        = name
      self .title       = title
      self .providerUrl = providerUrl
      self .components  = components
   }
}
