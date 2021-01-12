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
   
   @MFString public final var url           : [String]
   @SFNode   public final var internalScene : X3DScene?

   public final override var isExternProto : Bool { true }
   
   public final var loadState = SFEnum <X3DLoadState> (wrappedValue: .NOT_STARTED_STATE)

   // Construction
   
   internal init (executionContext : X3DExecutionContext, url : [String])
   {
      self .url = url
      
      super .init (executionContext .browser!, executionContext)
      
      addChildObjects ($url,
                       $internalScene,
                       loadState)
      
      $url .setName ("url")
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
   
   public final override var proto : X3DProtoDeclaration?
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
               self .setLoadState (self .proto != nil ? .COMPLETE_STATE : .FAILED_STATE)
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
         
         if let proto = proto
         {
            for field in getUserDefinedFields ()
            {
               removeUserDefinedField (field .getName ())
            }
      
            for field in proto .getUserDefinedFields ()
            {
               addUserDefinedField (field .getAccessType (), field .getName (), field)
            }
         }
         
         set_live ()
      }
      else
      {
         internalScene = nil

      }
   }
}
