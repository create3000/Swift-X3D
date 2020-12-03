//
//  File.swift
//  
//
//  Created by Holger Seelig on 17.11.20.
//

import Cocoa

internal class X3DFlyViewer :
   X3DViewer
{
   // Member types
   
   enum Mode
   {
      case none
      case move
      case pan
   }
   
   // Properties
   
   private final var fromVector : Vector3f = .zero
   private final var toVector   : Vector3f = .zero
   private final var direction  : Vector3f = .zero
   private final var startTime  : TimeInterval = 0
   private final var mode       : Mode = .none
   
   // Static properties
   
   private static let SPEED_FACTOR          : Float = 0.007
   private static let SHIFT_SPEED_FACTOR    : Float = 4 * SPEED_FACTOR
   private static let ROTATION_SPEED_FACTOR : Float = 1.4
   private static let ROTATION_LIMIT        : Float = 40
   
   private final var renderer      : Renderer!
   private final var renderContext : RenderContext!

   internal override func initialize ()
   {
      super .initialize ()
      
      renderer      = browser! .renderers .pop ()
      renderContext = RenderContext (renderer: renderer, isTransparent: false)
   }

   // Event handlers
   
   internal final override func mouseDown (with event : NSEvent)
   {
      disconnect ()
      activeViewpoint .transitionStop ()
      
      isActive = true
      
      browser! .addCollision (object: self)
      browser! .setNeedsDisplay ()
      
      if event .modifierFlags .contains (NSEvent .ModifierFlags .option)
      {
         // Look around.
         fromVector = trackballProjectToSphere (from: browser! .convert (event .locationInWindow, from: nil))
      }
      else
      {
         // Move.
         let point = browser! .convert (event .locationInWindow, from: nil)
         
         fromVector = Vector3f (Float (point .x), 0, Float (-point .y))
         toVector   = fromVector
         mode       = .move
      }
   }
   
   private final var shift : Bool = false
   
   internal final override func mouseDragged (with event : NSEvent)
   {
      shift = event .modifierFlags .contains (NSEvent .ModifierFlags .shift)
      
      if event .modifierFlags .contains (NSEvent .ModifierFlags .option)
      {
         // Look around.
         var orientation = activeViewpoint .userOrientation
         let toVector    = trackballProjectToSphere (from: browser! .convert (event .locationInWindow, from: nil))

         orientation = orientation * Rotation4f (from: toVector, to: fromVector)
         orientation = activeViewpoint .straightenHorizon (orientation) * orientation

         activeViewpoint .orientationOffset = orientation * activeViewpoint .getOrientation () .inverse

         fromVector = toVector
      }
      else
      {
         // Fly.
         let point = browser! .convert (event .locationInWindow, from: nil)
         
         toVector  = Vector3f (Float (point .x), 0, Float (-point .y))
         direction = toVector - fromVector

         addFly ()
      }
   }
   
   internal final override func mouseUp (with event : NSEvent)
   {
      disconnect ()

      isActive = false
      mode     = .none

      browser! .removeCollision (object: self)
      browser! .setNeedsDisplay ()
   }
   
   internal final override func scrollWheel (with event : NSEvent)
   {
      
   }
   
   private final func fly ()
   {
      let now      = browser! .currentTime
      let dt       = Float (now - startTime)
      let upVector = activeViewpoint .upVector

      // Rubberband values

      let up = Rotation4f (from: .yAxis, to: upVector)

      let rubberBandRotation = direction .z > 0
                               ? Rotation4f (from: up * direction, to: up * .zAxis)
                               : Rotation4f (from: up * -.zAxis, to: up * direction)

      let rubberBandLength = length (direction)

      // Position offset

      var speedFactor = 1 - rubberBandRotation .angle / (.pi / 2)

      speedFactor *= activeNavigationInfo .speed
      speedFactor *= activeViewpoint .getSpeedFactor ()
      speedFactor *= shift ? X3DFlyViewer .SHIFT_SPEED_FACTOR : X3DFlyViewer .SPEED_FACTOR
      speedFactor *= dt

      let translation = getTranslationOffset (speedFactor * direction)

      activeViewpoint .positionOffset += browser! .collider .constrain (translation, true)
      
      // Rotation

      var weight = X3DFlyViewer .ROTATION_SPEED_FACTOR * dt

      weight *= pow (rubberBandLength / (rubberBandLength + X3DFlyViewer .ROTATION_LIMIT), 2)

      activeViewpoint .orientationOffset = slerp (.identity, rubberBandRotation, t: weight) * activeViewpoint .orientationOffset

      // GeoRotation

      let geoRotation = Rotation4f (from: upVector, to: activeViewpoint .upVector)

      activeViewpoint .orientationOffset = geoRotation * activeViewpoint .orientationOffset

      startTime = now
   }

   private final func addFly ()
   {
      startTime = browser! .currentTime
      
      browser! .addBrowserInterest (event: .Browser_Done, id: "fly", method: X3DFlyViewer .fly, object: self)
      browser! .setNeedsDisplay ()
   }
   
   internal func getTranslationOffset (_ translation : Vector3f) -> Vector3f { return .zero }

   private final func disconnect ()
   {
      browser! .removeBrowserInterest (event: .Browser_Done, id: "fly",  method: X3DFlyViewer .fly, object: self)
   }
   
   internal final override func render (_ commandBuffer : MTLCommandBuffer)
   {
      guard browser! .getBrowserOptions () .Rubberband else { return }
      guard mode != .none else { return }

      let width     = Float (browser! .viewport [2])
      let height    = Float (browser! .viewport [3])
      let scale     = Float (browser! .layer! .contentsScale)
      let fromPoint = Vector4f (fromVector .x * scale, -fromVector .z * scale, 0, 1)
      let toPoint   = Vector4f (toVector   .x * scale, -toVector   .z * scale, 0, 1)
      
      let direction = toPoint - fromPoint
      let offset    = normalize (Vector4f (-direction .y, direction .x, 0, 0)) * 3
      let black     = Color4f (.zero, 1)
      
      let vertices = [
         // Black rectable vertices
         
         x3d_VertexIn (fogDepth: 0, color: black, texCoords: (.zero, .zero), normal: .zero, point: fromPoint - offset),
         x3d_VertexIn (fogDepth: 0, color: black, texCoords: (.zero, .zero), normal: .zero, point: fromPoint + offset),
         x3d_VertexIn (fogDepth: 0, color: black, texCoords: (.zero, .zero), normal: .zero, point: toPoint   + offset),
         
         x3d_VertexIn (fogDepth: 0, color: black, texCoords: (.zero, .zero), normal: .zero, point: fromPoint - offset),
         x3d_VertexIn (fogDepth: 0, color: black, texCoords: (.zero, .zero), normal: .zero, point: toPoint   + offset),
         x3d_VertexIn (fogDepth: 0, color: black, texCoords: (.zero, .zero), normal: .zero, point: toPoint   - offset),

         // White line vertices
         
         x3d_VertexIn (fogDepth: 0, color: .one, texCoords: (.zero, .zero), normal: .zero, point: fromPoint),
         x3d_VertexIn (fogDepth: 0, color: .one, texCoords: (.zero, .zero), normal: .zero, point: toPoint),
      ]
      
      let buffer = browser! .device! .makeBuffer (bytes: vertices,
                                                  length: vertices .count * MemoryLayout <x3d_VertexIn> .stride,
                                                  options: [ ])!
      
      // Prepare render pass, ie. create render encoder with appropriate settings.
      
      guard let renderPassDescriptor = browser! .currentRenderPassDescriptor else { return }
      
      renderPassDescriptor .depthAttachment .loadAction      = .dontCare
      renderPassDescriptor .colorAttachments [0] .loadAction = .dontCare

      guard let renderEncoder = commandBuffer .makeRenderCommandEncoder (descriptor: renderPassDescriptor) else { return }
      
      // Set default sampler for texture channels 0 and 1.
      renderEncoder .setFragmentSamplerState (browser! .defaultSampler, index: 0)
      renderEncoder .setFragmentSamplerState (browser! .defaultSampler, index: 1)
      
      // Set render pipeline states.
      renderEncoder .setDepthStencilState (renderer .browser .depthStencilState [false])
      renderEncoder .setRenderPipelineState (renderer .browser .renderPipelineState [.LineOpaque]!)

      // Set uniforms.
      let uniforms         = renderContext .uniforms
      let projectionMatrix = Camera .ortho (left: 0, right: width, bottom: 0, top: height, nearValue: -1, farValue: 1)

      uniforms .pointee .projectionMatrix = projectionMatrix
      uniforms .pointee .modelViewMatrix  = .identity
      uniforms .pointee .fog .type        = x3d_NoFog
      uniforms .pointee .colorMaterial    = true
     
      // Set buffers.
      renderEncoder .setVertexBuffer   (renderContext .uniformsBuffer, offset: 0, index: 1)
      renderEncoder .setFragmentBuffer (renderContext .uniformsBuffer, offset: 0, index: 1)
      
      // Draw black line.
      renderEncoder .setCullMode (.back)
      renderEncoder .setVertexBuffer (buffer, offset: 0, index: 0)
      renderEncoder .drawPrimitives (type: .triangle, vertexStart: 0, vertexCount: 6)
      
      // Draw white line.
      renderEncoder .setVertexBuffer (buffer, offset: 0, index: 0)
      renderEncoder .drawPrimitives (type: .line, vertexStart: 6, vertexCount: 2)

      // Finish render pass.
      
      renderEncoder .endEncoding ()
   }
}
