//
//  EdgeEnhancementVolumeStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class EdgeEnhancementVolumeStyle :
   X3DComposableVolumeRenderStyleNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "EdgeEnhancementVolumeStyle" }
   internal final override class var component      : String { "VolumeRendering" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "renderStyle" }

   // Fields

   @SFColorRGBA public final var edgeColor         : Color4f = Color4f (0, 0, 0, 1)
   @SFFloat     public final var gradientThreshold : Float = 0.4
   @SFNode      public final var surfaceNormals    : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.EdgeEnhancementVolumeStyle)

      addField (.inputOutput, "metadata",          $metadata)
      addField (.inputOutput, "enabled",           $enabled)
      addField (.inputOutput, "edgeColor",         $edgeColor)
      addField (.inputOutput, "gradientThreshold", $gradientThreshold)
      addField (.inputOutput, "surfaceNormals",    $surfaceNormals)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> EdgeEnhancementVolumeStyle
   {
      return EdgeEnhancementVolumeStyle (with: executionContext)
   }
}
