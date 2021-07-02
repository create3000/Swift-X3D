//
//  ComposedCubeMapTexture.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ComposedCubeMapTexture :
   X3DEnvironmentTextureNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ComposedCubeMapTexture" }
   internal final override class var component      : String { "CubeMapTexturing" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "texture" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFNode public final var frontTexture  : X3DNode?
   @SFNode public final var backTexture   : X3DNode?
   @SFNode public final var leftTexture   : X3DNode?
   @SFNode public final var rightTexture  : X3DNode?
   @SFNode public final var topTexture    : X3DNode?
   @SFNode public final var bottomTexture : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ComposedCubeMapTexture)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOutput, "frontTexture",  $frontTexture)
      addField (.inputOutput, "backTexture",   $backTexture)
      addField (.inputOutput, "leftTexture",   $leftTexture)
      addField (.inputOutput, "rightTexture",  $rightTexture)
      addField (.inputOutput, "topTexture",    $topTexture)
      addField (.inputOutput, "bottomTexture", $bottomTexture)
      
      addFieldAlias (alias: "front",  name: "frontTexture")
      addFieldAlias (alias: "back",   name: "backTexture")
      addFieldAlias (alias: "left",   name: "leftTexture")
      addFieldAlias (alias: "right",  name: "rightTexture")
      addFieldAlias (alias: "top",    name: "topTexture")
      addFieldAlias (alias: "bottom", name: "bottomTexture")
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ComposedCubeMapTexture
   {
      return ComposedCubeMapTexture (with: executionContext)
   }
}
