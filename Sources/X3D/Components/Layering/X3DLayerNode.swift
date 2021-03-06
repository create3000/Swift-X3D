//
//  X3DLayerNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public class X3DLayerNode :
   X3DNode
{
   // Fields

   @SFBool public final var isPickable : Bool = true
   @SFNode public final var viewport   : X3DNode?
   
   // Properties
   
   public private(set) final var viewportNode : X3DViewportNode?
   internal private(set) final var groupNode  : X3DGroupingNode
   
   private final var defaultNavigationInfoNode : NavigationInfo
   private final var defaultViewpointNode      : X3DViewpointNode
   private final var defaultBackgroundNode     : X3DBackgroundNode
   private final var defaultFogNode            : Fog

   public final let navigationInfoStack : X3DBindableStack <NavigationInfo>
   public final let viewpointStack      : X3DBindableStack <X3DViewpointNode>
   public final let backgroundStack     : X3DBindableStack <X3DBackgroundNode>
   public final let fogStack            : X3DBindableStack <Fog>
   
   public final let navigationInfoList : X3DBindableList <NavigationInfo>
   public final let viewpointList      : X3DBindableList <X3DViewpointNode>
   public final let backgroundList     : X3DBindableList <X3DBackgroundNode>
   public final let fogList            : X3DBindableList <Fog>
   
   public final var navigationInfoNode : NavigationInfo { navigationInfoStack .top }
   public final var viewpointNode      : X3DViewpointNode { viewpointStack .top }
   public final var backgroundNode     : X3DBackgroundNode { backgroundStack .top }
   public final var fogNode            : Fog { fogStack .top }

   internal final var isLayer0 : Bool = false

   // Construction
   
   public init (browser : X3DBrowser, executionContext : X3DExecutionContext?, viewpointNode: X3DViewpointNode, groupNode : X3DGroupingNode)
   {
      let defaultNavigationInfoNode = NavigationInfo (with: executionContext!)
      let defaultViewpointNode      = viewpointNode
      let defaultBackgroundNode     = Background (with: executionContext!)
      let defaultFogNode            = Fog (with: executionContext!)
      
      self .groupNode                 = groupNode
      self .defaultNavigationInfoNode = defaultNavigationInfoNode
      self .defaultViewpointNode      = defaultViewpointNode
      self .defaultBackgroundNode     = defaultBackgroundNode
      self .defaultFogNode            = defaultFogNode
      self .navigationInfoStack       = X3DBindableStack (with: executionContext!, default: defaultNavigationInfoNode)
      self .viewpointStack            = X3DBindableStack (with: executionContext!, default: defaultViewpointNode)
      self .backgroundStack           = X3DBindableStack (with: executionContext!, default: defaultBackgroundNode)
      self .fogStack                  = X3DBindableStack (with: executionContext!, default: defaultFogNode)
      self .navigationInfoList        = X3DBindableList (with: executionContext!, default: defaultNavigationInfoNode)
      self .viewpointList             = X3DBindableList (with: executionContext!, default: defaultViewpointNode)
      self .backgroundList            = X3DBindableList (with: executionContext!, default: defaultBackgroundNode)
      self .fogList                   = X3DBindableList (with: executionContext!, default: defaultFogNode)

      super .init (browser, executionContext)

      types .append (.X3DLayerNode)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      $viewport .addInterest ("set_viewport", { $0 .set_viewport () }, self)
      
      groupNode .isPrivate = true
      
      defaultBackgroundNode .isHidden = !isLayer0
      defaultFogNode        .isHidden = true
      
      defaultNavigationInfoNode .setup ()
      defaultViewpointNode      .setup ()
      defaultBackgroundNode     .setup ()
      defaultFogNode            .setup ()
      viewpointStack            .setup ()
      navigationInfoStack       .setup ()
      backgroundStack           .setup ()
      fogStack                  .setup ()
      viewpointList             .setup ()
      navigationInfoList        .setup ()
      backgroundList            .setup ()
      fogList                   .setup ()

      set_viewport ()
   }

   internal final func bindFirstBindables ()
   {
      let renderer = browser! .renderers .pop ()
      
      traverse (.Camera, renderer)
      browser! .renderers .push (renderer)
      
      let navigationInfoNode = navigationInfoList .first ()
      let viewpointNode      = viewpointList      .first (name: executionContext! .getWorldURL () .fragment)
      let backgroundNode     = backgroundList     .first ()
      let fogNode            = fogList            .first ()
      
      navigationInfoStack .pushOnTop (node: navigationInfoNode)
      viewpointStack      .pushOnTop (node: viewpointNode)
      backgroundStack     .pushOnTop (node: backgroundNode)
      fogStack            .pushOnTop (node: fogNode)

      viewpointNode .resetUserOffsets ()
   }
   
   public final func getUserViewpoints () -> [X3DViewpointNode]
   {
      return viewpointList .list .filter { !$0 .description .isEmpty }
   }
   
   // Event handlers
   
   private final func set_viewport ()
   {
      viewportNode = viewport? .innerNode as? X3DViewportNode ?? browser! .defaultViewportNode
   }
   
   // Rendering
   
   internal final func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      renderer .layerNode = self
      
      switch type
      {
         case .Pointer:
            pointer (type, renderer)
         case .Camera:
            camera (type, renderer)
         case .Picking:
            break
         case .Collision:
            collision (type, renderer)
         case .Depth:
            break
         case .Render:
            render (type, renderer)
      }
   }
   
   private final func pointer (_ type : TraverseType, _ renderer : Renderer)
   {
      guard isPickable else { return }
      
      let viewport  = viewportNode! .makeRectangle (with: renderer .browser)
      let nearValue = navigationInfoNode .nearValue
      let farValue  = navigationInfoNode .farValue (viewpointNode)
      
      if let selectedLayer = renderer .browser .selectedLayer
      {
         guard selectedLayer === self else { return }
      }
      else
      {
         guard renderer .browser .pointerInRectangle (viewport) else { return }
      }
      
      renderer .viewport .append (viewport)
      renderer .projectionMatrix .push (viewpointNode .makeProjectionMatrix (viewport, nearValue, farValue))
      renderer .viewViewMatrix   .push (viewpointNode .viewMatrix)
      renderer .modelViewMatrix  .push (viewpointNode .viewMatrix)
      
      renderer .browser .makeHitRay (renderer .projectionMatrix .top, renderer .viewport .last!)

      groupNode .traverse (type, renderer)

      renderer .modelViewMatrix  .pop ()
      renderer .viewViewMatrix   .pop ()
      renderer .projectionMatrix .pop ()
      renderer .viewport .removeLast ()
   }
   
   private final func camera (_ type : TraverseType, _ renderer : Renderer)
   {
      renderer .modelViewMatrix .push (.identity)

      groupNode .traverse (type, renderer)

      renderer .modelViewMatrix .pop ()

      // Update lists and stacks.
      
      navigationInfoList .update (with: self, stack: navigationInfoStack)
      viewpointList      .update (with: self, stack: viewpointStack)
      backgroundList     .update (with: self, stack: backgroundStack)
      fogList            .update (with: self, stack: fogStack)
      
      viewpointNode .update ()
   }

   private final func collision (_ type : TraverseType, _ renderer : Renderer)
   {
      guard !navigationInfoNode .transitionActive else { return }

      let viewport         = viewportNode! .makeRectangle (with: renderer .browser)
      let collisionRadius  = navigationInfoNode .collisionRadius
      let avatarHeight     = navigationInfoNode .avatarHeight
      let size             = max (collisionRadius * 2, avatarHeight * 2)
      let projectionMatrix = Camera .ortho (left: -size, right: size, bottom: -size, top: size, nearValue: -size, farValue: size)
      
      renderer .viewport .append (viewport)
      renderer .projectionMatrix .push (projectionMatrix)
      renderer .viewViewMatrix   .push (viewpointNode .viewMatrix)
      renderer .modelViewMatrix  .push (viewpointNode .viewMatrix)

      groupNode .traverse (.Collision, renderer)
      renderer .collision ()
      
      renderer .modelViewMatrix  .pop ()
      renderer .viewViewMatrix   .pop ()
      renderer .projectionMatrix .pop ()
      renderer .viewport .removeLast ()
   }
   
   private final func render (_ type : TraverseType, _ renderer : Renderer)
   {
      let viewport  = viewportNode! .makeRectangle (with: renderer .browser)
      let nearValue = navigationInfoNode .nearValue
      let farValue  = navigationInfoNode .farValue (viewpointNode)
      
      renderer .viewport .append (viewport)
      renderer .projectionMatrix .push (viewpointNode .makeProjectionMatrix (viewport, nearValue, farValue))
      renderer .viewViewMatrix   .push (viewpointNode .viewMatrix)
      renderer .modelViewMatrix  .push (viewpointNode .viewMatrix)
      
      navigationInfoNode .push (renderer)
      fogNode .push (renderer)
      
      groupNode .traverse (type, renderer)
      renderer .render ()
      
      fogNode .pop (renderer)
      navigationInfoNode .pop (renderer)

      renderer .modelViewMatrix  .pop ()
      renderer .viewViewMatrix   .pop ()
      renderer .projectionMatrix .pop ()
      renderer .viewport .removeLast ()
   }
}
