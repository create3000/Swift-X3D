//
//  TextureCoordinateGenerator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TextureCoordinateGenerator :
   X3DTextureCoordinateNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TextureCoordinateGenerator" }
   internal final override class var component      : String { "Texturing" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "texCoord" }

   // Fields

   @SFString public final var mode      : String = "SPHERE"
   @MFFloat  public final var parameter : [Float]

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TextureCoordinateGenerator)

      addField (.inputOutput, "metadata",  $metadata)
      addField (.inputOutput, "mode",      $mode)
      addField (.inputOutput, "parameter", $parameter)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TextureCoordinateGenerator
   {
      return TextureCoordinateGenerator (with: executionContext)
   }
}
