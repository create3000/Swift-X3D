//
//  X3DProtoDeclaration.swift
//  X3D
//
//  Created by Holger Seelig on 27.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DProtoDeclaration :
   X3DProtoDeclarationNode
{
   // Properties
   
   @SFNode public private(set) var body : X3DExecutionContext?

   // Construction
   
   internal init (executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addChildObjects ($body)
      
      self .body = X3DExecutionContext (executionContext .browser!, executionContext)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      body! .setup ()
   }
}