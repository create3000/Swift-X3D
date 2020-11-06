//
//  BlendedVolumeStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class BlendedVolumeStyle :
   X3DComposableVolumeRenderStyleNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "BlendedVolumeStyle" }
   public final override class var component      : String { "VolumeRendering" }
   public final override class var componentLevel : Int32 { 3 }
   public final override class var containerField : String { "renderStyle" }

   // Fields

   @SFFloat  public final var weightConstant1         : Float = 0.5
   @SFFloat  public final var weightConstant2         : Float = 0.5
   @SFString public final var weightFunction1         : String = "CONSTANT"
   @SFString public final var weightFunction2         : String = "CONSTANT"
   @SFNode   public final var weightTransferFunction1 : X3DNode?
   @SFNode   public final var weightTransferFunction2 : X3DNode?
   @SFNode   public final var renderStyle             : X3DNode?
   @SFNode   public final var voxels                  : X3DNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.BlendedVolumeStyle)

      addField (.inputOutput, "metadata",                $metadata)
      addField (.inputOutput, "enabled",                 $enabled)
      addField (.inputOutput, "weightConstant1",         $weightConstant1)
      addField (.inputOutput, "weightConstant2",         $weightConstant2)
      addField (.inputOutput, "weightFunction1",         $weightFunction1)
      addField (.inputOutput, "weightFunction2",         $weightFunction2)
      addField (.inputOutput, "weightTransferFunction1", $weightTransferFunction1)
      addField (.inputOutput, "weightTransferFunction2", $weightTransferFunction2)
      addField (.inputOutput, "renderStyle",             $renderStyle)
      addField (.inputOutput, "voxels",                  $voxels)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> BlendedVolumeStyle
   {
      return BlendedVolumeStyle (with: executionContext)
   }
}
