//
//  MultiTextureCoordinate.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class MultiTextureCoordinate :
   X3DTextureCoordinateNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "MultiTextureCoordinate" }
   internal final override class var component      : String { "Texturing" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "texCoord" }

   // Fields

   @MFNode public final var texCoord : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.MultiTextureCoordinate)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "texCoord", $texCoord)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> MultiTextureCoordinate
   {
      return MultiTextureCoordinate (with: executionContext)
   }
}
