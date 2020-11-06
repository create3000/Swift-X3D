//
//  TextureProjectorPerspective.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TextureProjectorPerspective :
   X3DTextureProjectorNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "TextureProjectorPerspective" }
   public final override class var component      : String { "ProjectiveTextureMapping" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFFloat public final var fieldOfView : Float = 0.7854

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TextureProjectorPerspective)

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

      $fieldOfView .unit = .angle
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TextureProjectorPerspective
   {
      return TextureProjectorPerspective (with: executionContext)
   }
}
