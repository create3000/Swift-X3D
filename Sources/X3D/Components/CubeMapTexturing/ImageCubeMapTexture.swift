//
//  ImageCubeMapTexture.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ImageCubeMapTexture :
   X3DEnvironmentTextureNode,
   X3DUrlObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ImageCubeMapTexture" }
   internal final override class var component      : String { "CubeMapTexturing" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "texture" }

   // Fields
   
   @MFString public final var url : [String]
   
   // X3DUrlObject
   
   @SFEnum public final var loadState : X3DLoadState = .NOT_STARTED_STATE

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initUrlObject ()

      types .append (.ImageCubeMapTexture)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.inputOutput,    "url",               $url)
      addField (.initializeOnly, "textureProperties", $textureProperties)
      
      addChildObjects ($loadState)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ImageCubeMapTexture
   {
      return ImageCubeMapTexture (with: executionContext)
   }
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
   }
   
   // Property access
   
   public final override var checkTextureLoadState : X3DLoadState { checkLoadState }
}
