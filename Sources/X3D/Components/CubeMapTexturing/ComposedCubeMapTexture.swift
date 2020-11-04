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
   
   public final override class var typeName       : String { "ComposedCubeMapTexture" }
   public final override class var component      : String { "CubeMapTexturing" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "texture" }

   // Fields

   @SFNode public final var front  : X3DNode?
   @SFNode public final var back   : X3DNode?
   @SFNode public final var left   : X3DNode?
   @SFNode public final var right  : X3DNode?
   @SFNode public final var top    : X3DNode?
   @SFNode public final var bottom : X3DNode?

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ComposedCubeMapTexture)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "front",    $front)
      addField (.inputOutput, "back",     $back)
      addField (.inputOutput, "left",     $left)
      addField (.inputOutput, "right",    $right)
      addField (.inputOutput, "top",      $top)
      addField (.inputOutput, "bottom",   $bottom)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ComposedCubeMapTexture
   {
      return ComposedCubeMapTexture (with: executionContext)
   }
}