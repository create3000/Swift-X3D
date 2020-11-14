//
//  ImageTexture3D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ImageTexture3D :
   X3DTexture3DNode,
   X3DUrlObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ImageTexture3D" }
   internal final override class var component      : String { "Texturing3D" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "texture" }

   // Fields
   
   @MFString public final var url : [String]
   
   // X3DUrlObject
   
   @SFEnum public final var loadState : X3DLoadState = .NOT_STARTED_STATE

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initUrlObject ()

      types .append (.ImageTexture3D)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.inputOutput,    "url",               $url)
      addField (.initializeOnly, "repeatS",           $repeatS)
      addField (.initializeOnly, "repeatT",           $repeatT)
      addField (.initializeOnly, "repeatR",           $repeatR)
      addField (.initializeOnly, "textureProperties", $textureProperties)
      
      addChildObjects ($loadState)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ImageTexture3D
   {
      return ImageTexture3D (with: executionContext)
   }
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
   }
   
   public final override var checkTextureLoadState : X3DLoadState { checkLoadState }
}
