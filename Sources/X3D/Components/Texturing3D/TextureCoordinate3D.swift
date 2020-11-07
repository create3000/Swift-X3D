//
//  TextureCoordinate3D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TextureCoordinate3D :
   X3DTextureCoordinateNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TextureCoordinate3D" }
   internal final override class var component      : String { "Texturing3D" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "texCoord" }

   // Fields

   @MFVec3f public final var point : MFVec3f .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TextureCoordinate3D)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "point",    $point)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TextureCoordinate3D
   {
      return TextureCoordinate3D (with: executionContext)
   }
}
