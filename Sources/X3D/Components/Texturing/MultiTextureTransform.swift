//
//  MultiTextureTransform.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class MultiTextureTransform :
   X3DTextureTransformNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "MultiTextureTransform" }
   internal final override class var component      : String { "Texturing" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "textureTransform" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @MFNode public final var textureTransform : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.MultiTextureTransform)

      addField (.inputOutput, "metadata",         $metadata)
      addField (.inputOutput, "textureTransform", $textureTransform)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> MultiTextureTransform
   {
      return MultiTextureTransform (with: executionContext)
   }
}
