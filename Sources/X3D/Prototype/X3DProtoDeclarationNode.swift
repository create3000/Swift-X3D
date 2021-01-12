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
   
   @SFNode public final var metadata : X3DNode?
   
   public final override var canUserDefinedFields : Bool { true }

   public var isExternProto : Bool { false }
   
   public var proto : X3DProtoDeclaration? { nil }

   // Instance construction
   
   internal final func createInstance (with executionContext : X3DExecutionContext) -> X3DPrototypeInstance
   {
      return createInstance (with: executionContext, setup: true)
   }
   
   internal final func createInstance (with executionContext : X3DExecutionContext, setup : Bool) -> X3DPrototypeInstance
   {
      let instance = X3DPrototypeInstance (with: executionContext, from: self)
      
      if setup { instance .setup () }
      
      return instance
   }
}
