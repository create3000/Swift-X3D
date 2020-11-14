//
//  TextureProjectorParallel.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TextureProjectorParallel :
   X3DTextureProjectorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TextureProjectorParallel" }
   internal final override class var component      : String { "ProjectiveTextureMapping" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }

   // Fields

   @MFFloat public final var fieldOfView : [Float] = [-1, -1, 1, 1]

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TextureProjectorParallel)

      addField (.inputOutput, "metadata",     $metadata)
      addField (.inputOutput, "description",  $description)
      addField (.inputOutput, "on",           $on)
      addField (.inputOutput, "global",       $global)
      addField (.inputOutput, "location",     $location)
      addField (.inputOutput, "direction",    $direction)
      addField (.inputOutput, "upVector",     $upVector)
      addField (.inputOutput, "fieldOfView",  $fieldOfView)
      addField (.inputOutput, "nearDistance", $nearDistance)
      addField (.inputOutput, "farDistance",  $farDistance)
      addField (.outputOnly,  "aspectRatio",  $aspectRatio)
      addField (.inputOutput, "texture",      $texture)

      $fieldOfView .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TextureProjectorParallel
   {
      return TextureProjectorParallel (with: executionContext)
   }
}
