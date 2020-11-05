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
   
   public final override var proto : X3DProtoDeclaration?
   {
      if let internalScene = internalScene
      {
         if let fragment = fileURL? .fragment
         {
            return internalScene .protos .first { $0 .identifier == fragment }
         }
         
         return internalScene .protos .first
      }
      
      return nil
   }
   
   // Properties
   
   @SFNode internal final var internalScene : X3DScene?
   private final var fileURL : URL?

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
      
      scene! .$isLive .addInterest (X3DExternProtoDeclaration .set_live, self)

      $url .addInterest (X3DExternProtoDeclaration .set_url, self)
      
      requestImmediateLoad ()
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
      setLoadState (.NOT_STARTED_STATE)

      requestImmediateLoad ()
   }

   // Load handling
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.IN_PROGRESS_STATE)

      // Start load.

      let url = self .url .map { URL (string: $0, relativeTo: executionContext! .worldURL) } .compactMap { $0 }
      
      browser! .inlineQueue .async
      {
         guard let browser = self .browser else { return }
         
         for URL in url
         {
            if let scene = try? browser .createX3DFromURL (url: [URL])
            {
               DispatchQueue .main .async
               {
                  self .fileURL = URL
                  
                  self .replaceScene (scene: scene)
                  self .setLoadState (.COMPLETE_STATE)
               }
               
               return
            }
         }
         
         DispatchQueue .main .async
         {
            self .fileURL = nil
            
            self .replaceScene (scene: nil)
            self .setLoadState (.FAILED_STATE)
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
