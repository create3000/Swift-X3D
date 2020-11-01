//
//  CollisionSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CollisionSensor :
   X3DChildNode,
   X3DSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "CollisionSensor" }
   public final override class var component      : String { "RigidBodyPhysics" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool public final var enabled       : Bool = true
   @SFBool public final var isActive      : Bool = false
   @MFNode public final var intersections : MFNode <X3DNode> .Value
   @MFNode public final var contacts      : MFNode <X3DNode> .Value
   @SFNode public final var collider      : X3DNode?

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initSensorNode ()

      types .append (.CollisionSensor)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOutput, "enabled",       $enabled)
      addField (.outputOnly,  "isActive",      $isActive)
      addField (.outputOnly,  "intersections", $intersections)
      addField (.outputOnly,  "contacts",      $contacts)
      addField (.inputOutput, "collider",      $collider)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CollisionSensor
   {
      return CollisionSensor (with: executionContext)
   }
}
