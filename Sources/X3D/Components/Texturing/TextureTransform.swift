//
//  TextureTransform.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TextureTransform :
   X3DTextureTransformNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TextureTransform" }
   internal final override class var component      : String { "Texturing" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "textureTransform" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFVec2f public final var translation : Vector2f = .zero
   @SFFloat public final var rotation    : Float = 0
   @SFVec2f public final var scale       : Vector2f = Vector2f (1, 1)
   @SFVec2f public final var center      : Vector2f = .zero

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TextureTransform)

      addField (.inputOutput, "metadata",    $metadata)
      addField (.inputOutput, "translation", $translation)
      addField (.inputOutput, "rotation",    $rotation)
      addField (.inputOutput, "scale",       $scale)
      addField (.inputOutput, "center",      $center)

      $rotation .unit = .angle
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TextureTransform
   {
      return TextureTransform (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      addInterest ("eventsProcessed", { $0 .eventsProcessed () }, self)
      
      eventsProcessed ()
   }
   
   private final func eventsProcessed ()
   {
      // Tc' = -C × S × R × C × T × Tc
      
      var matrix = Matrix3f .identity
      
      if center != Vector2f .zero
      {
         var centerMatrix = Matrix3f .identity
         
         centerMatrix [2] [0] = -center .x
         centerMatrix [2] [1] = -center .y
         
         matrix *= centerMatrix
      }

      if scale != Vector2f .one
      {
         var scaleMatrix = Matrix3f .identity
         
         scaleMatrix [0] [0] = scale .x
         scaleMatrix [1] [1] = scale .y
         
         matrix *= scaleMatrix
      }

      if rotation != 0
      {
         var rotationMatrix = Matrix3f .identity
         
         let sinAngle = sin (rotation)
         let cosAngle = cos (rotation)

         rotationMatrix [0] [0] = cosAngle
         rotationMatrix [0] [1] = sinAngle

         rotationMatrix [1] [0] = -sinAngle
         rotationMatrix [1] [1] = cosAngle

         matrix *= rotationMatrix
      }

      if center != Vector2f .zero
      {
         var centerMatrix = Matrix3f .identity
         
         centerMatrix [2] [0] = center .x
         centerMatrix [2] [1] = center .y
         
         matrix *= centerMatrix
      }

      if translation != Vector2f .zero
      {
         var translationMatrix = Matrix3f .identity
         
         translationMatrix [2] [0] = translation .x
         translationMatrix [2] [1] = translation .y
         
         matrix *= translationMatrix
      }
      
      textureMatrix = Matrix4f (columns: (Vector4f (matrix [0], 0),
                                          Vector4f (matrix [1], 0),
                                          Vector4f (0, 0, 1, 0),
                                          Vector4f (matrix [2] [0], matrix [2] [1], 0, 1)))
   }
}
