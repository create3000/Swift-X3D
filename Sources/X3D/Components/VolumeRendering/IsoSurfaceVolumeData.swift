//
//  IsoSurfaceVolumeData.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class IsoSurfaceVolumeData :
   X3DVolumeDataNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "IsoSurfaceVolumeData" }
   internal final override class var component      : String { "VolumeRendering" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFFloat public final var contourStepSize  : Float = 0
   @MFFloat public final var surfaceValues    : [Float]
   @SFFloat public final var surfaceTolerance : Float = 0
   @MFNode  public final var renderStyle      : [X3DNode?]
   @SFNode  public final var gradients        : X3DNode?
   @SFNode  public final var voxels           : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.IsoSurfaceVolumeData)

      addField (.inputOutput,    "metadata",         $metadata)
      addField (.inputOutput,    "dimensions",       $dimensions)
      addField (.inputOutput,    "contourStepSize",  $contourStepSize)
      addField (.inputOutput,    "surfaceValues",    $surfaceValues)
      addField (.inputOutput,    "surfaceTolerance", $surfaceTolerance)
      addField (.initializeOnly, "bboxCenter",       $bboxCenter)
      addField (.initializeOnly, "bboxSize",         $bboxSize)
      addField (.inputOutput,    "renderStyle",      $renderStyle)
      addField (.inputOutput,    "gradients",        $gradients)
      addField (.inputOutput,    "voxels",           $voxels)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> IsoSurfaceVolumeData
   {
      return IsoSurfaceVolumeData (with: executionContext)
   }
}
