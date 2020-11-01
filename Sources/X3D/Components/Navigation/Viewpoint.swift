//
//  Viewpoint.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Viewpoint :
   X3DViewpointNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Viewpoint" }
   public final override class var component      : String { "Navigation" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFVec3f public final var position         : Vector3f = Vector3f (0, 0, 10)
   @SFVec3f public final var centerOfRotation : Vector3f = Vector3f .zero
   @SFFloat public final var fieldOfView      : Float = 0.7854

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Viewpoint)

      addField (.inputOutput, "metadata",          $metadata)
      addField (.inputOnly,   "set_bind",          $set_bind)
      addField (.inputOutput, "description",       $description)
      addField (.inputOutput, "position",          $position)
      addField (.inputOutput, "orientation",       $orientation)
      addField (.inputOutput, "centerOfRotation",  $centerOfRotation)
      addField (.inputOutput, "fieldOfView",       $fieldOfView)
      addField (.inputOutput, "jump",              $jump)
      addField (.inputOutput, "retainUserOffsets", $retainUserOffsets)
      addField (.outputOnly,  "isBound",           $isBound)
      addField (.outputOnly,  "bindTime",          $bindTime)

      $position         .unit = .length
      $centerOfRotation .unit = .length
      $fieldOfView      .unit = .angle
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Viewpoint
   {
      return Viewpoint (with: executionContext)
   }
   
   // Property access
   
   internal final override func getPosition () -> Vector3f { position }
   internal final override func getCenterOfRotation () -> Vector3f { centerOfRotation }

   private final func getFieldOfView () -> Float
   {
      guard fieldOfView > 0 && fieldOfView < Float .pi else
      {
         return Float .pi / 4
      }
      
      return fieldOfView
   }
   
   // Rendering
   
   internal final override func makeProjectionMatrix (_ viewport : Vector4i, _ nearValue : Float, _ farValue : Float) -> Matrix4f
   {
      return X3DCamera .perspective (fieldOfView: getFieldOfView (),
                                     nearValue: nearValue,
                                     farValue: farValue,
                                     width: Float (viewport [2]),
                                     height: Float (viewport [3]))
   }
}
