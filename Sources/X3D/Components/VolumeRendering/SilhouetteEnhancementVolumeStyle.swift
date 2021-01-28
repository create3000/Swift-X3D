//
//  SilhouetteEnhancementVolumeStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class SilhouetteEnhancementVolumeStyle :
   X3DComposableVolumeRenderStyleNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "SilhouetteEnhancementVolumeStyle" }
   internal final override class var component      : String { "VolumeRendering" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "renderStyle" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFFloat public final var silhouetteRetainedOpacity : Float = 1
   @SFFloat public final var silhouetteBoundaryOpacity : Float = 0
   @SFFloat public final var silhouetteSharpness       : Float = 0.5
   @SFNode  public final var surfaceNormals            : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.SilhouetteEnhancementVolumeStyle)

      addField (.inputOutput, "metadata",                  $metadata)
      addField (.inputOutput, "enabled",                   $enabled)
      addField (.inputOutput, "silhouetteRetainedOpacity", $silhouetteRetainedOpacity)
      addField (.inputOutput, "silhouetteBoundaryOpacity", $silhouetteBoundaryOpacity)
      addField (.inputOutput, "silhouetteSharpness",       $silhouetteSharpness)
      addField (.inputOutput, "surfaceNormals",            $surfaceNormals)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SilhouetteEnhancementVolumeStyle
   {
      return SilhouetteEnhancementVolumeStyle (with: executionContext)
   }
}
