//
//  Inline.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class Inline :
   X3DChildNode,
   X3DUrlObject,
   X3DBoundedObject,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Inline" }
   public final override class var component      : String { "Networking" }
   public final override class var componentLevel : Int32 { 3 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool   public final var load       : Bool = true
   @MFString public final var url        : MFString .Value
   @SFVec3f  public final var bboxSize   : Vector3f = Vector3f (-1, -1, -1)
   @SFVec3f  public final var bboxCenter : Vector3f = Vector3f .zero
   
   // X3DUrlObject
   
   @SFEnum public final var loadState : X3DLoadState = .NOT_STARTED_STATE
   
   // Properties
   
   @SFNode internal final var internalScene : X3DScene?
   @SFNode private final var groupNode : Group!

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      self .groupNode = Group (with: executionContext)
      
      super .init (executionContext .browser!, executionContext)
      
      initUrlObject ()
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)

      types .append (.Inline)

      addField (.inputOutput,    "metadata",   $metadata)
      addField (.inputOutput,    "load",       $load)
      addField (.inputOutput,    "url",        $url)
      addField (.initializeOnly, "bboxSize",   $bboxSize)
      addField (.initializeOnly, "bboxCenter", $bboxCenter)
      
      addChildObjects ($loadState)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Inline
   {
      return Inline (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      scene! .$isLive .addInterest (Inline .set_live, self)
      
      $load .addInterest (Inline .set_load, self)
      $url  .addInterest (Inline .set_url,  self)

      groupNode .$isCameraObject   .addFieldInterest (to: $isCameraObject)
      groupNode .$isPickableObject .addFieldInterest (to: $isPickableObject)

      groupNode .isPrivate = true
      groupNode .setup ()
      
      requestImmediateLoad ()
   }

   // Bounded object
   
   public final var bbox : Box3f { groupNode .bbox }

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
   
   private final func set_load ()
   {
      guard checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.NOT_STARTED_STATE)
      
      if load
      {
         requestImmediateLoad ()
      }
      else
      {
         replaceScene (scene: nil)
      }
   }
   
   private final func set_url ()
   {
      guard load else { return }
      guard checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.NOT_STARTED_STATE)
      
      requestImmediateLoad ()
   }

   // Scene handling
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.IN_PROGRESS_STATE)

      // Start load.

      let url = self .url .map { URL (string: $0, relativeTo: executionContext! .worldURL) } .compactMap { $0 }
      
      browser! .inlineQueue .async
      {
         guard let browser = self .browser else { return }
         
         do
         {
            let scene = try browser .createX3DFromURL (url: url)
            
            DispatchQueue .main .async
            {
               self .replaceScene (scene: scene)
               self .setLoadState (.COMPLETE_STATE)
            }
         }
         catch
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
      internalScene? .$rootNodes .removeFieldInterest (to: groupNode .$children)
      groupNode .children .removeAll ()
      
      if let scene = scene
      {
         internalScene = scene
         
         internalScene! .executionContext = executionContext!
         internalScene! .isPrivate        = executionContext! .isPrivate

         internalScene! .$rootNodes .addFieldInterest (to: groupNode .$children)
         groupNode .children .append (contentsOf: internalScene! .rootNodes)

         set_live ()
      }
      else
      {
         internalScene = nil
      }
   }
   
   // Rendering
   
   internal final override func traverse (_ type : X3DTraverseType, _ renderer : X3DRenderer)
   {
      groupNode .traverse (type, renderer)
   }
}