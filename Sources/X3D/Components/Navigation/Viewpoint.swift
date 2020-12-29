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
   
   internal final override class var typeName       : String { "Viewpoint" }
   internal final override class var component      : String { "Navigation" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFVec3f public final var position         : Vector3f = Vector3f (0, 0, 10)
   @SFVec3f public final var centerOfRotation : Vector3f = .zero
   @SFFloat public final var fieldOfView      : Float = 0.7854
   
   // Animation
   
   @SFNode private final var fieldOfViewInterpolator : ScalarInterpolator?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      fieldOfViewInterpolator = ScalarInterpolator (with: executionContext)
      
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
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      fieldOfViewInterpolator! .key = [0, 1]
      
      fieldOfViewInterpolator! .setup ()
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
   
   // Animation
   
   internal final override func setInterpolators (from fromViewpoint : X3DViewpointNode)
   {
      if let fromViewpoint = fromViewpoint as? Viewpoint
      {
         let scale = fromViewpoint .getFieldOfView () / getFieldOfView ()

         fieldOfViewInterpolator! .keyValue = [scale, fieldOfViewScale]

         fieldOfViewScale = scale
      }
      else
      {
         fieldOfViewInterpolator! .keyValue = [fieldOfViewScale, fieldOfViewScale]
      }
   }
   
   // Rendering
   
   internal final override func makeProjectionMatrix (_ viewport : Vector4i, _ nearValue : Float, _ farValue : Float) -> Matrix4f
   {
      return Camera .perspective (fieldOfView: getFieldOfView (),
                                  nearValue: nearValue,
                                  farValue: farValue,
                                  width: Float (viewport [2]),
                                  height: Float (viewport [3]))
   }

   internal final override func getScreenScale (_ point : Vector3f, _ viewport : Vector4i) -> Vector3f
   {
      // Returns the screen scale in meter/pixel for on pixel.

      let width  = viewport [2]
      let height = viewport [3]
      var size   = abs (point .z) * tan (getFieldOfView () / 2) * 2

      size /= Float (width > height ? height : width)

      return Vector3f (size, size, size)
   }
}
