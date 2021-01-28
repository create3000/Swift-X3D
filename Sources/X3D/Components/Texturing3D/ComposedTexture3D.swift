//
//  ComposedTexture3D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ComposedTexture3D :
   X3DTexture3DNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ComposedTexture3D" }
   internal final override class var component      : String { "Texturing3D" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "texture" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @MFNode public final var texture : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ComposedTexture3D)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.initializeOnly, "repeatS",           $repeatS)
      addField (.initializeOnly, "repeatT",           $repeatT)
      addField (.initializeOnly, "repeatR",           $repeatR)
      addField (.initializeOnly, "textureProperties", $textureProperties)
      addField (.inputOutput,    "texture",           $texture)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ComposedTexture3D
   {
      return ComposedTexture3D (with: executionContext)
   }
}
