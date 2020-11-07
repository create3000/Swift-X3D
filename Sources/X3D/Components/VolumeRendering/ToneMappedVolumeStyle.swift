//
//  ToneMappedVolumeStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ToneMappedVolumeStyle :
   X3DComposableVolumeRenderStyleNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ToneMappedVolumeStyle" }
   internal final override class var component      : String { "VolumeRendering" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "renderStyle" }

   // Fields

   @SFColorRGBA public final var coolColor      : Color4f = Color4f (0, 0, 1, 0)
   @SFColorRGBA public final var warmColor      : Color4f = Color4f (1, 1, 0, 0)
   @SFNode      public final var surfaceNormals : X3DNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ToneMappedVolumeStyle)

      addField (.inputOutput, "metadata",       $metadata)
      addField (.inputOutput, "enabled",        $enabled)
      addField (.inputOutput, "coolColor",      $coolColor)
      addField (.inputOutput, "warmColor",      $warmColor)
      addField (.inputOutput, "surfaceNormals", $surfaceNormals)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ToneMappedVolumeStyle
   {
      return ToneMappedVolumeStyle (with: executionContext)
   }
}
