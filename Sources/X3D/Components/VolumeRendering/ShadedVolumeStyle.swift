//
//  ShadedVolumeStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ShadedVolumeStyle :
   X3DComposableVolumeRenderStyleNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ShadedVolumeStyle" }
   internal final override class var component      : String { "VolumeRendering" }
   internal final override class var componentLevel : Int32 { 4 }
   internal final override class var containerField : String { "renderStyle" }

   // Fields

   @SFBool   public final var lighting       : Bool = false
   @SFBool   public final var shadows        : Bool = false
   @SFString public final var phaseFunction  : String = "Henyey-Greenstein"
   @SFNode   public final var material       : X3DNode?
   @SFNode   public final var surfaceNormals : X3DNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ShadedVolumeStyle)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "enabled",        $enabled)
      addField (.inputOutput,    "lighting",       $lighting)
      addField (.inputOutput,    "shadows",        $shadows)
      addField (.initializeOnly, "phaseFunction",  $phaseFunction)
      addField (.inputOutput,    "material",       $material)
      addField (.inputOutput,    "surfaceNormals", $surfaceNormals)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ShadedVolumeStyle
   {
      return ShadedVolumeStyle (with: executionContext)
   }
}
