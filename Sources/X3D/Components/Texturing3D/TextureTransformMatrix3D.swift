//
//  TextureTransformMatrix3D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TextureTransformMatrix3D :
   X3DTextureTransformNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TextureTransformMatrix3D" }
   internal final override class var component      : String { "Texturing3D" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFMatrix4f public final var matrix : Matrix4f = .identity

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TextureTransformMatrix3D)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "matrix",   $matrix)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TextureTransformMatrix3D
   {
      return TextureTransformMatrix3D (with: executionContext)
   }
}
