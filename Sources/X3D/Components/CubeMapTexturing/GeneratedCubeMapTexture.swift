//
//  GeneratedCubeMapTexture.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GeneratedCubeMapTexture :
   X3DEnvironmentTextureNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "GeneratedCubeMapTexture" }
   public final override class var component      : String { "CubeMapTexturing" }
   public final override class var componentLevel : Int32 { 3 }
   public final override class var containerField : String { "texture" }

   // Fields

   @SFString public final var update : String = "NONE"
   @SFInt32  public final var size   : Int32 = 128

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.GeneratedCubeMapTexture)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.inputOutput,    "update",            $update)
      addField (.initializeOnly, "size",              $size)
      addField (.initializeOnly, "textureProperties", $textureProperties)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GeneratedCubeMapTexture
   {
      return GeneratedCubeMapTexture (with: executionContext)
   }
}