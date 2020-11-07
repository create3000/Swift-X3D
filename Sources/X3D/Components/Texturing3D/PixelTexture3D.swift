//
//  PixelTexture3D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class PixelTexture3D :
   X3DTexture3DNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "PixelTexture3D" }
   internal final override class var component      : String { "Texturing3D" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "texture" }

   // Fields

   @MFInt32 public final var image : MFInt32 .Value = [0, 0, 0, 0]

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PixelTexture3D)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.inputOutput,    "image",             $image)
      addField (.initializeOnly, "repeatS",           $repeatS)
      addField (.initializeOnly, "repeatT",           $repeatT)
      addField (.initializeOnly, "repeatR",           $repeatR)
      addField (.initializeOnly, "textureProperties", $textureProperties)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> PixelTexture3D
   {
      return PixelTexture3D (with: executionContext)
   }
}
