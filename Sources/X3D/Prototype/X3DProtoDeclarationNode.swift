//
//  X3DProtoDeclarationNode.swift
//  X3D
//
//  Created by Holger Seelig on 27.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DProtoDeclarationNode :
   X3DBaseNode
{
   // Properties
   
   public final override var canUserDefinedFields : Bool { true }

   public var isExternProto : Bool { false }
   
   // Instance construction
   
   public final func createInstance (executionContext : X3DExecutionContext, setup : Bool = true) -> X3DPrototypeInstance
   {
      let instance = X3DPrototypeInstance (with: executionContext, from: self)
      
      if setup
      {
         instance .setup ()
      }
      
      return instance
   }
}