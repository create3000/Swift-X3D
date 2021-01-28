//
//  VisibilitySensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class VisibilitySensor :
   X3DEnvironmentalSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "VisibilitySensor" }
   internal final override class var component      : String { "EnvironmentalSensor" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }
   
   // Properties
   
   private final var visible   : Bool = false
   private final var traversed : Bool = true

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.VisibilitySensor)

      addField (.inputOutput, "metadata",  $metadata)
      addField (.inputOutput, "enabled",   $enabled)
      addField (.inputOutput, "size",      $size)
      addField (.inputOutput, "center",    $center)
      addField (.outputOnly,  "enterTime", $enterTime)
      addField (.outputOnly,  "exitTime",  $exitTime)
      addField (.outputOnly,  "isActive",  $isActive)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> VisibilitySensor
   {
      return VisibilitySensor (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      scene! .$isLive .addInterest ("set_enabled", { $0 .set_enabled () }, self)
      
      $enabled .addInterest ("set_enabled", { $0 .set_enabled () }, self)
      
      set_enabled ()
   }
   
   // Event handlers
   
   private final func set_enabled ()
   {
      guard let scene = scene else { return }
      
      if enabled && scene .isLive
      {
         browser! .addBrowserInterest (event: .Browser_Sensors, id: "update", handler: { $0 .update () }, requester: self)
      }
      else
      {
         browser! .removeBrowserInterest (event: .Browser_Sensors, id: "update", requester: self)

         if isActive
         {
            isActive = false
            exitTime = browser! .currentTime
         }
      }
   }
   
   private final func update ()
   {
      if visible && traversed
      {
         if !isActive
         {
            isActive  = true
            enterTime = browser! .currentTime
         }
      }
      else
      {
         if isActive
         {
            isActive = false
            exitTime = browser! .currentTime
         }
      }

      visible   = false
      traversed = false
   }
   
   // Rendering
   
   internal final override func traverse (_ type: TraverseType, _ renderer: Renderer)
   {
      guard enabled else { return }

      guard type == .Render else { return }

      guard !visible else { return }

      traversed = true

      if size == -.one
      {
         visible = true
      }
      else
      {
         let bbox = renderer .modelViewMatrix .top * Box3f (size: size, center: center)

         visible = ViewVolume .intersects (with: bbox, renderer .projectionMatrix .top, renderer .viewport .last!)
      }
   }
}
