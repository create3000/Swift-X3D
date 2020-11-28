//
//  BoundaryEnhancementVolumeStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class BoundaryEnhancementVolumeStyle :
   X3DComposableVolumeRenderStyleNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "BoundaryEnhancementVolumeStyle" }
   internal final override class var component      : String { "VolumeRendering" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "renderStyle" }

   // Fields

   @SFFloat public final var retainedOpacity : Float = 0.2
   @SFFloat public final var boundaryOpacity : Float = 0.9
   @SFFloat public final var opacityFactor   : Float = 2

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.BoundaryEnhancementVolumeStyle)

      addField (.inputOutput, "metadata",        $metadata)
      addField (.inputOutput, "enabled",         $enabled)
      addField (.inputOutput, "retainedOpacity", $retainedOpacity)
      addField (.inputOutput, "boundaryOpacity", $boundaryOpacity)
      addField (.inputOutput, "opacityFactor",   $opacityFactor)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> BoundaryEnhancementVolumeStyle
   {
      return BoundaryEnhancementVolumeStyle (with: executionContext)
   }
}
