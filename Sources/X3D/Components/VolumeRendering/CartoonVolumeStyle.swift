//
//  CartoonVolumeStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CartoonVolumeStyle :
   X3DComposableVolumeRenderStyleNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "CartoonVolumeStyle" }
   internal final override class var component      : String { "VolumeRendering" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "renderStyle" }

   // Fields

   @SFInt32     public final var colorSteps      : Int32 = 4
   @SFColorRGBA public final var orthogonalColor : Color4f = Color4f (1, 1, 1, 1)
   @SFColorRGBA public final var parallelColor   : Color4f = Color4f (0, 0, 0, 1)
   @SFNode      public final var surfaceNormals  : X3DNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.CartoonVolumeStyle)

      addField (.inputOutput, "metadata",        $metadata)
      addField (.inputOutput, "enabled",         $enabled)
      addField (.inputOutput, "colorSteps",      $colorSteps)
      addField (.inputOutput, "orthogonalColor", $orthogonalColor)
      addField (.inputOutput, "parallelColor",   $parallelColor)
      addField (.inputOutput, "surfaceNormals",  $surfaceNormals)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CartoonVolumeStyle
   {
      return CartoonVolumeStyle (with: executionContext)
   }
}
