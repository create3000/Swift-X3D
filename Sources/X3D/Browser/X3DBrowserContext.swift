//
//  X3DBrowserContext.swift
//  X3D
//
//  Created by Holger Seelig on 06.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Cocoa
import Metal

public class X3DBrowserContext :
   X3DBrowserSurface,
   X3DRoutingContext,
   X3DCoreContext,
   X3DGeometry2DContext,
   X3DGeometry3DContext,
   X3DKeyDeviceSensorContext,
   X3DLayeringContext,
   X3DLightingContext,
   X3DNavigationContext,
   X3DNetworkingContext,
   X3DPointingDeviceSensorContext,
   X3DRenderingContext,
   X3DScriptingContext,
   X3DShapeContext,
   X3DTextContext,
   X3DTexturingContext,
   X3DTimeContext
{
   // Public properties
   
   internal final var world        : X3DWorld!
   internal final var currentScene : X3DScene!
   
   // Properties
   
   internal var browser : X3DBrowser { self as! X3DBrowser }
   internal private(set) final var internalScene : X3DScene!

   // Context properties
   
   internal private(set) final var routingContextProperties              : X3DRoutingContextProperties!
   internal private(set) final var coreContextProperties                 : X3DCoreContextProperties!
   internal private(set) final var geometry2DContextProperties           : X3DGeometry2DContextProperties!
   internal private(set) final var geometry3DContextProperties           : X3DGeometry3DContextProperties!
   internal private(set) final var keyDeviceSensorContextProperties      : X3DKeyDeviceSensorContextProperties!
   internal private(set) final var layeringContextProperties             : X3DLayeringContextProperties!
   internal private(set) final var lightingContextProperties             : X3DLightingContextProperties!
   internal private(set) final var navigationContextProperties           : X3DNavigationContextProperties!
   internal private(set) final var networkingContextProperties           : X3DNetworkingContextProperties!
   internal private(set) final var pointingDeviceSensorContextProperties : X3DPointingDeviceSensorContextProperties!
   internal private(set) final var renderingContextProperties            : X3DRenderingContextProperties!
   internal private(set) final var scriptingContextProperties            : X3DScriptingContextProperties!
   internal private(set) final var shapeContextProperties                : X3DShapeContextProperties!
   internal private(set) final var textContextProperties                 : X3DTextContextProperties!
   internal private(set) final var texturingContextProperties            : X3DTexturingContextProperties!
   internal private(set) final var timeContextProperties                 : X3DTimeContextProperties!

   // Console handling
   
   internal final let console = X3DConsole ()
   
   // Initialization

   public override func initialize ()
   {
      super .initialize ()
      
      // Create browser's internal scene.
      
      internalScene = X3DScene (with: browser)
      
      // Init context objects.

      routingContextProperties              = X3DRoutingContextProperties              (with: internalScene)
      coreContextProperties                 = X3DCoreContextProperties                 (with: internalScene)
      geometry2DContextProperties           = X3DGeometry2DContextProperties           (with: internalScene)
      geometry3DContextProperties           = X3DGeometry3DContextProperties           (with: internalScene)
      keyDeviceSensorContextProperties      = X3DKeyDeviceSensorContextProperties      (with: internalScene)
      layeringContextProperties             = X3DLayeringContextProperties             (with: internalScene)
      lightingContextProperties             = X3DLightingContextProperties             (with: internalScene)
      navigationContextProperties           = X3DNavigationContextProperties           (with: internalScene)
      networkingContextProperties           = X3DNetworkingContextProperties           (with: internalScene)
      pointingDeviceSensorContextProperties = X3DPointingDeviceSensorContextProperties (with: internalScene)
      renderingContextProperties            = X3DRenderingContextProperties            (with: internalScene)
      scriptingContextProperties            = X3DScriptingContextProperties            (with: internalScene)
      shapeContextProperties                = X3DShapeContextProperties                (with: internalScene)
      textContextProperties                 = X3DTextContextProperties                 (with: internalScene)
      texturingContextProperties            = X3DTexturingContextProperties            (with: internalScene)
      timeContextProperties                 = X3DTimeContextProperties                 (with: internalScene)

      // Setup context objects.
      
      routingContextProperties              .setup ()
      coreContextProperties                 .setup ()
      geometry2DContextProperties           .setup ()
      geometry3DContextProperties           .setup ()
      keyDeviceSensorContextProperties      .setup ()
      layeringContextProperties             .setup ()
      lightingContextProperties             .setup ()
      navigationContextProperties           .setup ()
      networkingContextProperties           .setup ()
      pointingDeviceSensorContextProperties .setup ()
      renderingContextProperties            .setup ()
      scriptingContextProperties            .setup ()
      shapeContextProperties                .setup ()
      textContextProperties                 .setup ()
      texturingContextProperties            .setup ()
      timeContextProperties                 .setup ()

      // Make browser's internal scene live.
      
      internalScene .setup ()
      internalScene .beginUpdate ()
   }
   
   public var selection : Bool
   {
      get { pointingDeviceSensorContextProperties .selection }
      set { pointingDeviceSensorContextProperties .selection = newValue }
   }
   
   // Handle mouse events
   
   public override func mouseEntered (with event : NSEvent)
   {
      pointingDeviceSensorContextProperties .mouseEntered (with: event)
   }
   
   public override func mouseMoved (with event: NSEvent)
   {
      pointingDeviceSensorContextProperties .mouseMoved (with: event)
   }
   
   public override func mouseDown (with event : NSEvent)
   {
      pointingDeviceSensorContextProperties .mouseDown (with: event)
   }
   
   public override func mouseDragged (with event : NSEvent)
   {
      pointingDeviceSensorContextProperties .mouseDragged (with : event)
   }
   
   public override func mouseUp (with event : NSEvent)
   {
      pointingDeviceSensorContextProperties .mouseUp (with: event)
   }
   
   public override func mouseExited (with event : NSEvent)
   {
      pointingDeviceSensorContextProperties .mouseExited (with: event)
   }
   
   public override func scrollWheel (with event : NSEvent)
   {
      pointingDeviceSensorContextProperties .scrollWheel (with: event)
   }
   
   // Track mouse move, enter and leave events.
   
   public final override func updateTrackingAreas ()
   {
      trackingAreas .forEach { removeTrackingArea ($0) }
      
      addTrackingArea (NSTrackingArea (rect: bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited, .mouseMoved], owner: self))
   }
   
   // Handle key events
   
   public override var acceptsFirstResponder : Bool { true }
   
   public override func keyDown (with event : NSEvent)
   {
      keyDeviceSensorContextProperties .keyDown (with: event)
   }
   
   public override func keyUp (with event : NSEvent)
   {
      keyDeviceSensorContextProperties .keyUp (with: event)
   }
   
   // Keyedness of window
   
   @objc public func windowKeyednessChanged (_ note : Notification) { }
   
   public override func viewWillMove (toWindow newWindow : NSWindow?)
   {
      let notificationCenter = NotificationCenter .default
      
      if let oldWindow = window
      {
         notificationCenter .removeObserver (self, name: NSWindow .didBecomeKeyNotification, object: oldWindow)
         notificationCenter .removeObserver (self, name: NSWindow .didResignKeyNotification, object: oldWindow)
      }
      
      if let newWindow = newWindow
      {
         notificationCenter .addObserver (self, selector: #selector(windowKeyednessChanged(_:)), name: NSWindow .didBecomeKeyNotification, object: newWindow)
         notificationCenter .addObserver (self, selector: #selector(windowKeyednessChanged(_:)), name: NSWindow .didResignKeyNotification, object: newWindow)
      }
   }

   // Browser interests

   internal func callBrowserInterests (event : X3DBrowserEvent) { }

   // Rendering
   
   internal final func setNeedsDisplay ()
   {
      setNeedsDisplay (bounds)
   }
   
   public private(set) final var primitives = (points: 0, lines: 0, triangles: 0, opaqueShapes: 0, transparentShapes: 0)

   internal final override func update (_ commandBuffer : MTLCommandBuffer)
   {
      let renderer = renderers .pop ()
      
      commandBuffer .addCompletedHandler { _ in DispatchQueue .main .async { self .renderers .push (renderer) } }
      
      renderer .commandBuffer = commandBuffer
      
      advanceTime ()
      callBrowserInterests (event: .Browser_Event)
      processEvents ()

      world! .traverse (.Camera, renderer)
      
      if hasCollisions
      {
         collider .beginCollision ()
         world! .traverse (.Collision, collider)
         collider .endCollision ()
      }
      
      callBrowserInterests (event: .Browser_Sensors)
      processEvents ()

      renderer .beginRender ()
      world! .traverse (.Render, renderer)
      renderer .endRender ()
      
      primitives = renderer .primitives
      
      callBrowserInterests (event: .Browser_Done)
      
      viewerNode .render (commandBuffer)
   }
   
   deinit
   {
      // Keyedness of window
      NotificationCenter .default .removeObserver (self)
   }
}
