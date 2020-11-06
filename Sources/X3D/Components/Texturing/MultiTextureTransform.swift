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
   
   public final override class var typeName       : String { "MultiTextureTransform" }
   public final override class var component      : String { "Texturing" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "textureTransform" }

   // Fields

   @MFNode public final var textureTransform : MFNode <X3DNode> .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
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
