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
   
   public final override class var typeName       : String { "SilhouetteEnhancementVolumeStyle" }
   public final override class var component      : String { "VolumeRendering" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "renderStyle" }

   // Fields

   @SFFloat public final var silhouetteRetainedOpacity : Float = 1
   @SFFloat public final var silhouetteBoundaryOpacity : Float = 0
   @SFFloat public final var silhouetteSharpness       : Float = 0.5
   @SFNode  public final var surfaceNormals            : X3DNode?

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
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