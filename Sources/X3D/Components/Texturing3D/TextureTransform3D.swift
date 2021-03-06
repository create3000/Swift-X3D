//
//  TextureTransform3D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TextureTransform3D :
   X3DTextureTransformNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TextureTransform3D" }
   internal final override class var component      : String { "Texturing3D" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "textureTransform" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFVec3f    public final var translation : Vector3f = .zero
   @SFRotation public final var rotation    : Rotation4f = .identity
   @SFVec3f    public final var scale       : Vector3f = Vector3f (1, 1, 1)
   @SFVec3f    public final var center      : Vector3f = .zero

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TextureTransform3D)

      addField (.inputOutput, "metadata",    $metadata)
      addField (.inputOutput, "translation", $translation)
      addField (.inputOutput, "rotation",    $rotation)
      addField (.inputOutput, "scale",       $scale)
      addField (.inputOutput, "center",      $center)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TextureTransform3D
   {
      return TextureTransform3D (with: executionContext)
   }
}
