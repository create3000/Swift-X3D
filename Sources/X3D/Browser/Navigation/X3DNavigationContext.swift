//
//  X3DNavigationContext.swift
//  X3D
//
//  Created by Holger Seelig on 24.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DNavigationContextProperies :
   X3DBaseNode
{
   // Properties
   
   @SFNode public private(set) final var activeLayerNode          : X3DLayerNode?
   @SFNode public private(set) final var activeNavigationInfoNode : NavigationInfo?
   @SFNode public private(set) final var activeViewpointNode      : X3DViewpointNode?
   @MFEnum public final var availableViewers                      : MFEnum <X3DViewerType> .Value = [.NONE]
   @SFEnum public private(set) final var viewer                   : X3DViewerType = .NONE
   @SFNode public private(set) final var viewerNode               : X3DViewer?
   @SFNode private final var headlightNode                        : DirectionalLight?
   fileprivate final var headlightContainer                       : X3DLightContainer?
   
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
      headlightContainer = X3DLightContainer (lightNode: self .headlightNode!, modelViewMatrix: Matrix4f .identity)

      headlightNode! .setup ()
      
      // Viewer
      
      browser! .addBrowserInterest (event: .Browser_Initialized, method: X3DNavigationContextProperies .set_initialized, object: self)
      $viewer .addInterest (X3DNavigationContextProperies .set_viewer, self)
      
      set_viewer ()
   }
   
   private final func set_initialized ()
   {
      browser! .world .$activeLayerNode .addInterest (X3DNavigationContextProperies .set_activeLayer, self)

      set_activeLayer ()
   }
   
   private final func set_activeLayer ()
   {
      guard activeLayerNode != browser! .world .activeLayerNode else { return }
      
      activeLayerNode? .navigationInfoStack .removeInterest (X3DNavigationContextProperies .set_activeNavigationInfo, self)
      activeLayerNode? .viewpointStack      .removeInterest (X3DNavigationContextProperies .set_activeViewpoint,      self)

      activeLayerNode = browser! .world .activeLayerNode

      activeLayerNode? .navigationInfoStack .addInterest (X3DNavigationContextProperies .set_activeNavigationInfo, self)
      activeLayerNode? .viewpointStack      .addInterest (X3DNavigationContextProperies .set_activeViewpoint,      self)

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
      switch viewer
      {
         case .EXAMINE:
            viewerNode = X3DExamineViewer (with: executionContext!)
         case .WALK:
            viewerNode = X3DNoneViewer (with: executionContext!)
         case .FLY:
            viewerNode = X3DNoneViewer (with: executionContext!)
         case .PLANE:
            viewerNode = X3DNoneViewer (with: executionContext!)
         case .LOOKAT:
            viewerNode = X3DNoneViewer (with: executionContext!)
         default:
            viewerNode = X3DNoneViewer (with: executionContext!)
      }

      viewerNode! .setup ()
   }
}

public protocol X3DNavigationContext : class
{
   var browser                     : X3DBrowser { get }
   var navigationContextProperties : X3DNavigationContextProperies! { get }
}

extension X3DNavigationContext
{
   public var viewerNode : X3DViewer { navigationContextProperties .viewerNode! }
   internal var headlightContainer : X3DLightContainer { navigationContextProperties .headlightContainer! }
}
