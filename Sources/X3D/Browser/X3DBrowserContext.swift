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
   X3DShapeContext,
   X3DTexturingContext,
   X3DTimeContext,
   X3DInputOutput
{
   // Public properties
   
   @SFNode public internal(set) final var world        : X3DWorld!
   @SFNode public internal(set) final var currentScene : X3DScene!
   
   // Prpperties
   
   public var browser : X3DBrowser { self as! X3DBrowser }
   internal private(set) final var internalScene : X3DScene!

   // Context properties
   
   public private(set) final var routingContextProperties              : X3DRoutingContextProperies!
   public private(set) final var coreContextProperties                 : X3DCoreContextProperies!
   public private(set) final var geometry2DContextProperties           : X3DGeometry2DContextProperies!
   public private(set) final var geometry3DContextProperties           : X3DGeometry3DContextProperies!
   public private(set) final var keyDeviceSensorContextProperties      : X3DKeyDeviceSensorContextProperies!
   public private(set) final var layeringContextProperties             : X3DLayeringContextProperies!
   public private(set) final var lightingContextProperties             : X3DLightingContextProperies!
   public private(set) final var navigationContextProperties           : X3DNavigationContextProperies!
   public private(set) final var networkingContextProperties           : X3DNetworkingContextProperies!
   public private(set) final var pointingDeviceSensorContextProperties : X3DPointingDeviceSensorContextProperies!
   public private(set) final var renderingContextProperties            : X3DRenderingContextProperies!
   public private(set) final var shapeContextProperties                : X3DShapeContextProperies!
   public private(set) final var texturingContextProperties            : X3DTexturingContextProperies!
   public private(set) final var timeContextProperties                 : X3DTimeContextProperies!

   // Console handling
   
   public final let console = X3DConsole ()
   
   // Initialization

   public override func initialize ()
   {
      super .initialize ()
      
      // Create browser's internal scene.
      
      internalScene = X3DScene (with: browser)
      
      // Init context objects.

      routingContextProperties              = X3DRoutingContextProperies              (with: internalScene)
      coreContextProperties                 = X3DCoreContextProperies                 (with: internalScene)
      geometry2DContextProperties           = X3DGeometry2DContextProperies           (with: internalScene)
      geometry3DContextProperties           = X3DGeometry3DContextProperies           (with: internalScene)
      keyDeviceSensorContextProperties      = X3DKeyDeviceSensorContextProperies      (with: internalScene)
      layeringContextProperties             = X3DLayeringContextProperies             (with: internalScene)
      lightingContextProperties             = X3DLightingContextProperies             (with: internalScene)
      navigationContextProperties           = X3DNavigationContextProperies           (with: internalScene)
      networkingContextProperties           = X3DNetworkingContextProperies           (with: internalScene)
      pointingDeviceSensorContextProperties = X3DPointingDeviceSensorContextProperies (with: internalScene)
      renderingContextProperties            = X3DRenderingContextProperies            (with: internalScene)
      shapeContextProperties                = X3DShapeContextProperies                (with: internalScene)
      texturingContextProperties            = X3DTexturingContextProperies            (with: internalScene)
      timeContextProperties                 = X3DTimeContextProperies                 (with: internalScene)

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
      shapeContextProperties                .setup ()
      texturingContextProperties            .setup ()
      timeContextProperties                 .setup ()

      // Make browser's internal scene live.
      
      internalScene .setup ()
      internalScene .beginUpdate ()
   }
   
   // Handle mouse events
   
   public override func mouseEntered (with event : NSEvent)
   {
      pointingDeviceSensorContextProperties .mouseEntered (with: event)
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
   
   // Track mouse enter and leave events.
   
   public final override func updateTrackingAreas ()
   {
      trackingAreas .forEach { removeTrackingArea ($0) }
      
      addTrackingArea (NSTrackingArea (rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self))
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

   // Browser interests

   internal func callBrowserInterests (event : X3DBrowserEvent) { }

   // Rendering
   
   internal final func setNeedsDisplay ()
   {
      setNeedsDisplay (bounds)
   }

   internal final override func update (_ commandBuffer : MTLCommandBuffer)
   {
      renderer .primitives    = (0, 0, 0, 0, 0)
      renderer .commandBuffer = commandBuffer
      
      advanceTime ()
      
      callBrowserInterests (event: .Browser_Event)
      
      processEvents ()

      world! .traverse (.Camera, renderer)
      
      callBrowserInterests (event: .Browser_Sensors)
      
      processEvents ()

      renderer .beginRender ()
      world! .traverse (.Render, renderer)
      renderer .endRender ()
      
      callBrowserInterests (event: .Browser_Done)
   }
}
