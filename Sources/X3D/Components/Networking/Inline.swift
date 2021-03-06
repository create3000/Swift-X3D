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
   
   internal final override class var typeName       : String { "Inline" }
   internal final override class var component      : String { "Networking" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFBool   public final var load       : Bool = true
   @MFString public final var url        : [String]
   @SFVec3f  public final var bboxSize   : Vector3f = -.one
   @SFVec3f  public final var bboxCenter : Vector3f = .zero
   
   // X3DUrlObject
   
   public final var loadState = SFEnum <X3DLoadState> (wrappedValue: .NOT_STARTED_STATE)
   
   // Properties
   
   @SFNode public private(set) final var internalScene : X3DScene?
   @SFNode private final var groupNode : Group!

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
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
      
      addChildObjects (loadState,
                       $internalScene)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Inline
   {
      return Inline (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      scene! .$isLive .addInterest ("set_live", { $0 .set_live () }, self)
      
      $load .addInterest ("set_load", { $0 .set_load () }, self)
      $url  .addInterest ("set_url",  { $0 .set_url () },  self)

      groupNode .$isCameraObject   .addFieldInterest (to: $isCameraObject)
      groupNode .$isPickableObject .addFieldInterest (to: $isPickableObject)

      groupNode .isPrivate = true
      groupNode .setup ()
      
      if load
      {
         requestImmediateLoad ()
      }
   }

   // Bounded object
   
   public final var bbox : Box3f { groupNode .bbox }

   // Event handlers
   
   private final func set_live ()
   {
      guard let scene = scene else { return }
      
      if scene .isLive
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
      guard load && checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.NOT_STARTED_STATE)
      
      requestImmediateLoad ()
   }

   // Scene handling
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.IN_PROGRESS_STATE)

      // Start load.

      let url = self .url .map { URL (string: $0, relativeTo: executionContext! .getWorldURL ()) } .compactMap { $0 }
      
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
      guard let executionContext = executionContext else { return }
      
      internalScene? .endUpdate ()
      internalScene? .$rootNodes .removeFieldInterest (to: groupNode .$children)
      
      if let scene = scene
      {
         internalScene = scene
         
         internalScene! .executionContext = executionContext
         internalScene! .isPrivate        = executionContext .isPrivate
         groupNode .children              = internalScene! .rootNodes

         internalScene! .$rootNodes .addFieldInterest (to: groupNode .$children)

         set_live ()
      }
      else
      {
         internalScene       = nil
         groupNode .children = [ ]
      }
   }
   
   // Rendering
   
   internal final override func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      groupNode .traverse (type, renderer)
   }
}
