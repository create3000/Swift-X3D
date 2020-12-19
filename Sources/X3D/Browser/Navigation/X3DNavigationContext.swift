//
//  X3DNavigationContext.swift
//  X3D
//
//  Created by Holger Seelig on 24.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class X3DNavigationContextProperties :
   X3DBaseNode
{
   // Navigation properties
   
   @SFNode public private(set) final var activeLayerNode          : X3DLayerNode?
   @SFNode public private(set) final var activeNavigationInfoNode : NavigationInfo?
   @SFNode public private(set) final var activeViewpointNode      : X3DViewpointNode?
   @MFEnum public final var availableViewers                      : [X3DViewerType] = [.NONE]
   @SFEnum public private(set) final var viewer                   : X3DViewerType = .NONE
   @SFNode public private(set) final var viewerNode               : X3DViewer?
   @SFNode private final var headlightNode                        : DirectionalLight?
   fileprivate final var headlightContainer                       : LightContainer?
   
   // Collision properties
   
   fileprivate final var collisions =  NSHashTable <X3DBaseNode> (options: .weakMemory)
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      addChildObjects ($activeLayerNode,
                       $activeNavigationInfoNode,
                       $activeViewpointNode,
                       $availableViewers,
                       $viewer,
                       $viewerNode,
                       $headlightNode)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      // Headlight
      
      headlightNode      = DirectionalLight (with: executionContext!)
      headlightContainer = LightContainer (lightNode: self .headlightNode!, modelViewMatrix: Matrix4f .identity)

      headlightNode! .setup ()
      
      // Viewer
      
      browser! .addBrowserInterest (event: .Browser_Initialized, id: "set_initialized", method: X3DNavigationContextProperties .set_initialized, object: self)
      $viewer .addInterest ("set_viewer", X3DNavigationContextProperties .set_viewer, self)
      
      set_viewer ()
   }
   
   private final func set_initialized ()
   {
      browser! .world .$activeLayerNode .addInterest ("set_activeLayer", X3DNavigationContextProperties .set_activeLayer, self)

      set_activeLayer ()
   }
   
   private final func set_activeLayer ()
   {
      guard activeLayerNode != browser! .world .activeLayerNode else { return }
      
      activeLayerNode? .navigationInfoStack .removeInterest ("set_activeNavigationInfo", X3DNavigationContextProperties .set_activeNavigationInfo, self)
      activeLayerNode? .viewpointStack      .removeInterest ("set_activeViewpoint",      X3DNavigationContextProperties .set_activeViewpoint,      self)

      activeLayerNode = browser! .world .activeLayerNode

      activeLayerNode? .navigationInfoStack .addInterest ("set_activeNavigationInfo", X3DNavigationContextProperties .set_activeNavigationInfo, self)
      activeLayerNode? .viewpointStack      .addInterest ("set_activeViewpoint",      X3DNavigationContextProperties .set_activeViewpoint,      self)

      set_activeNavigationInfo ()
      set_activeViewpoint ()
   }
   
   private final func set_activeNavigationInfo ()
   {
      activeNavigationInfoNode? .$viewer           .removeFieldInterest (to: $viewer)
      activeNavigationInfoNode? .$availableViewers .removeFieldInterest (to: $availableViewers)
      
      activeNavigationInfoNode = activeLayerNode? .navigationInfoNode

      activeNavigationInfoNode? .$viewer           .addFieldInterest (to: $viewer)
      activeNavigationInfoNode? .$availableViewers .addFieldInterest (to: $availableViewers)
      
      viewer = activeNavigationInfoNode? .viewer ?? .NONE
      
      if let activeNavigationInfoNode = activeNavigationInfoNode
      {
         availableViewers .removeAll (keepingCapacity: true)
         availableViewers .append (contentsOf: activeNavigationInfoNode .availableViewers)
      }
      else
      {
         availableViewers .removeAll (keepingCapacity: true)
         availableViewers .append (contentsOf: [.NONE])
      }
   }
   
   private final func set_activeViewpoint ()
   {
      activeViewpointNode = activeLayerNode? .viewpointNode
   }
   
   private final func set_viewer ()
   {
      debugPrint(#function, viewer)
      
      switch viewer
      {
         case .EXAMINE:
            viewerNode = ExamineViewer (with: executionContext!)
         case .WALK:
            viewerNode = WalkViewer (with: executionContext!)
         case .FLY:
            viewerNode = FlyViewer (with: executionContext!)
         case .PLANE:
            viewerNode = NoneViewer (with: executionContext!)
         case .LOOKAT:
            viewerNode = NoneViewer (with: executionContext!)
         default:
            viewerNode = NoneViewer (with: executionContext!)
      }

      viewerNode! .setup ()
   }
}

internal protocol X3DNavigationContext : class
{
   var browser                     : X3DBrowser { get }
   var navigationContextProperties : X3DNavigationContextProperties! { get }
}

extension X3DNavigationContext
{
   public var viewerNode : X3DViewer { navigationContextProperties .viewerNode! }
   internal var headlightContainer : LightContainer { navigationContextProperties .headlightContainer! }
   
   internal func addCollision (object : X3DBaseNode) { navigationContextProperties .collisions .add (object) }
   internal func removeCollision (object : X3DBaseNode) { navigationContextProperties .collisions .remove (object) }
   internal var hasCollisions : Bool { navigationContextProperties .collisions .count != 0 }
}
