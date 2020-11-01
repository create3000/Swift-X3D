//
//  X3DExternProtoDeclaration.swift
//  X3D
//
//  Created by Holger Seelig on 27.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DExternProtoDeclaration :
   X3DProtoDeclarationNode,
   X3DUrlObject
{
   // Properties
   
   @SFEnum public final var loadState : X3DLoadState = .NOT_STARTED_STATE
   @MFString public final var url     : MFString .Value
   
   public final override var isExternProto : Bool { true }

   // Construction
   
   internal init (executionContext : X3DExecutionContext, url : [String])
   {
      super .init (executionContext .browser!, executionContext)
      
      addChildObjects ($loadState,
                       $url)
      
      self .url .append (contentsOf: url)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $url .addInterest (X3DExternProtoDeclaration .set_url, self)
      
      requestImmediateLoad ()
   }
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
   }
   
   // Event handlers
   
   private final func set_url ()
   {
      setLoadState (.NOT_STARTED_STATE)

      requestImmediateLoad ()
   }
}
