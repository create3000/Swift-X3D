//
//  ProximitySensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ProximitySensor :
   X3DEnvironmentalSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ProximitySensor" }
   internal final override class var component      : String { "EnvironmentalSensor" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFVec3f    public final var centerOfRotation_changed : Vector3f = .zero
   @SFRotation public final var orientation_changed      : Rotation4f = .identity
   @SFVec3f    public final var position_changed         : Vector3f = .zero
   
   // Properties
   
   private final var inside        : Bool = false
   private final var traversed     : Bool = true
   private final var viewpointNode : X3DViewpointNode? = nil
   private final var modelMatrix   : Matrix4f = .identity

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ProximitySensor)

      addField (.inputOutput, "metadata",                 $metadata)
      addField (.inputOutput, "enabled",                  $enabled)
      addField (.inputOutput, "size",                     $size)
      addField (.inputOutput, "center",                   $center)
      addField (.outputOnly,  "enterTime",                $enterTime)
      addField (.outputOnly,  "exitTime",                 $exitTime)
      addField (.outputOnly,  "isActive",                 $isActive)
      addField (.outputOnly,  "position_changed",         $position_changed)
      addField (.outputOnly,  "orientation_changed",      $orientation_changed)
      addField (.outputOnly,  "centerOfRotation_changed", $centerOfRotation_changed)

      $centerOfRotation_changed .unit = .length
      $position_changed         .unit = .length
      
      setCameraObject (true)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ProximitySensor
   {
      return ProximitySensor (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      scene! .$isLive .addInterest ("set_enabled", { $0 .set_enabled () }, self)
      
      $enabled        .addInterest ("set_enabled", { $0 .set_enabled () }, self)
      $size           .addInterest ("set_enabled", { $0 .set_enabled () }, self)
      $isCameraObject .addInterest ("set_enabled", { $0 .set_enabled () }, self)

      set_enabled ()
   }
   
   // Event handlers

   private final func setTraversed (_ value : Bool)
   {
      setCameraObject (value ? true : traversed)

      traversed = value
   }
   
   private final func set_enabled ()
   {
      guard let scene = scene else { return }
      
      if isCameraObject && enabled && size != .zero && scene .isLive
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
      if inside && traversed
      {
         if let viewpointNode = viewpointNode
         {
            var centerOfRotationMatrix = viewpointNode .modelMatrix
            centerOfRotationMatrix  = centerOfRotationMatrix .translate (viewpointNode .userCenterOfRotation)
            centerOfRotationMatrix *= modelMatrix .inverse

            modelMatrix *= viewpointNode .viewMatrix
            
            let transform        = decompose_transformation_matrix (modelMatrix)
            let position         = modelMatrix .inverse .origin
            let orientation      = transform .rotation .inverse
            let centerOfRotation = centerOfRotationMatrix .origin

            if isActive
            {
               if position_changed != position
               {
                  position_changed = position
               }

               if orientation_changed != orientation
               {
                  orientation_changed = orientation
               }

               if centerOfRotation_changed != centerOfRotation
               {
                  centerOfRotation_changed = centerOfRotation
               }
            }
            else
            {
               isActive  = true
               enterTime = browser! .currentTime

               position_changed         = position
               orientation_changed      = orientation
               centerOfRotation_changed = centerOfRotation
            }
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

      inside        = false
      viewpointNode = nil

      setTraversed (false)
   }
   
   internal final override func traverse (_ type: TraverseType, _ renderer: Renderer)
   {
      guard enabled else { return }

      switch type
      {
         case .Camera: do
         {
            viewpointNode = renderer .layerNode .viewpointNode
            modelMatrix   = renderer .modelViewMatrix .top
         }
         case .Render: do
         {
            guard !inside else { return }

            setTraversed (true)

            if size == -.one
            {
               inside = true
            }
            else
            {
               let bbox = Box3f (size: size, center: center)

               inside = bbox .contains (point: renderer .modelViewMatrix .top .inverse .origin)
            }
         }
         default:
            break
      }
   }
}
