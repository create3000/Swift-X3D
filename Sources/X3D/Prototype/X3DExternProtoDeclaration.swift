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
   // Common properties
   
   internal final override class var typeName : String { "X3DExternProtoDeclaration" }
   
   // Properties
   
   @SFEnum   public   final var loadState     : X3DLoadState = .NOT_STARTED_STATE
   @MFString public   final var url           : [String]
   @SFNode   internal final var internalScene : X3DScene?

   public final override var isExternProto : Bool { true }

   // Construction
   
   internal init (executionContext : X3DExecutionContext, url : [String])
   {
      super .init (executionContext .browser!, executionContext)
      
      addChildObjects ($loadState,
                       $url,
                       $internalScene)
      
      self .url .append (contentsOf: url)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      scene! .$isLive .addInterest ("set_live", X3DExternProtoDeclaration .set_live, self)

      $url .addInterest ("set_url", X3DExternProtoDeclaration .set_url, self)
   }
   
   // Event handlers
   
   private final func set_live ()
   {
      if scene! .isLive
      {
         internalScene? .beginUpdate ()
      }
      else
      {
         internalScene? .endUpdate ()
      }
   }

   private final func set_url ()
   {
      guard checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.NOT_STARTED_STATE)

      requestImmediateLoad ()
   }
   
   // Property access
   
   public final override func getProto () -> X3DProtoDeclaration?
   {
      if let internalScene = internalScene
      {
         if let fragment = internalScene .getWorldURL () .fragment
         {
            return internalScene .getProtoDeclarations () .first { $0 .getName () == fragment }
         }
         
         return internalScene .getProtoDeclarations () .first
      }
      
      return nil
   }

   // Load handling
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.IN_PROGRESS_STATE)

      // Start load.
      
      guard let executionContext = executionContext else { return }

      let url = self .url .map { URL (string: $0, relativeTo: executionContext .getWorldURL ()) } .compactMap { $0 }
      
      browser! .inlineQueue .async
      {
         guard let browser = self .browser else { return }
         
         if let scene = try? browser .createX3DFromURL (url: url)
         {
            DispatchQueue .main .async
            {
               self .replaceScene (scene: scene)
               self .setLoadState (.COMPLETE_STATE)
            }
         }
         else
         {
            DispatchQueue .main .async
            {
               self .replaceScene (scene: nil)
               self .setLoadState (.FAILED_STATE)
            }
         }
      }
   }
   
   private final func replaceScene (scene : X3DScene?)
   {
      internalScene? .endUpdate ()
      
      if let scene = scene
      {
         internalScene = scene
         
         internalScene! .executionContext = executionContext!
         internalScene! .isPrivate        = executionContext! .isPrivate
         
         set_live ()
      }
      else
      {
         internalScene = nil
      }
   }
}
