//
//  OrthoViewpoint.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class OrthoViewpoint :
   X3DViewpointNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "OrthoViewpoint" }
   internal final override class var component      : String { "Navigation" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFVec3f public final var position         : Vector3f = Vector3f (0, 0, 10)
   @SFVec3f public final var centerOfRotation : Vector3f = .zero
   @MFFloat public final var fieldOfView      : MFFloat .Value = [-1, -1, 1, 1]

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.OrthoViewpoint)

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
      $fieldOfView      .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> OrthoViewpoint
   {
      return OrthoViewpoint (with: executionContext)
   }
   
   // Property access
   
   internal final override func getPosition () -> Vector3f { position }
   internal final override func getCenterOfRotation () -> Vector3f { centerOfRotation }

   private var minimumX : Float
   {
      (fieldOfView .count > 0 ? fieldOfView [0] : -1) * fieldOfViewScale
   }

   private var minimumY : Float
   {
      (fieldOfView .count > 1 ? fieldOfView [1] : -1) * fieldOfViewScale
   }

   private var maximumX : Float
   {
      (fieldOfView .count > 2 ? fieldOfView [2] : 1) * fieldOfViewScale
   }

   private var maximumY : Float
   {
      (fieldOfView .count > 3 ? fieldOfView [3] : 1) * fieldOfViewScale
   }

   private var sizeX : Float
   {
      maximumX - minimumX
   }

   private var sizeY : Float
   {
      maximumY - minimumY
   }

   // Rendering
   
   internal final override func makeProjectionMatrix (_ viewport : Vector4i, _ nearValue : Float, _ farValue : Float) -> Matrix4f
   {
      let width  = Float (viewport [2])
      let height = Float (viewport [3])
      let aspect = width / height

      if aspect > sizeX / sizeY
      {
         let center  = (minimumX + maximumX) / 2
         let size1_2 = (sizeY * aspect) / 2

         return Camera .ortho (left: center - size1_2,
                               right: center + size1_2,
                               bottom: minimumY,
                               top: maximumY,
                               nearValue: nearValue,
                               farValue: farValue)
      }
      else
      {
         let center  = (minimumY + maximumY) / 2
         let size1_2 = (sizeX / aspect) / 2

         return Camera .ortho (left: minimumX,
                               right: maximumX,
                               bottom: center - size1_2,
                               top: center + size1_2,
                               nearValue: nearValue,
                               farValue: farValue)
      }
   }
}
