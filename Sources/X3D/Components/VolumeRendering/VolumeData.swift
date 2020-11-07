//
//  VolumeData.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class VolumeData :
   X3DVolumeDataNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "VolumeData" }
   internal final override class var component      : String { "VolumeRendering" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFNode public final var renderStyle : X3DNode?
   @SFNode public final var voxels      : X3DNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.VolumeData)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.inputOutput,    "dimensions",  $dimensions)
      addField (.initializeOnly, "bboxSize",    $bboxSize)
      addField (.initializeOnly, "bboxCenter",  $bboxCenter)
      addField (.inputOutput,    "renderStyle", $renderStyle)
      addField (.inputOutput,    "voxels",      $voxels)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> VolumeData
   {
      return VolumeData (with: executionContext)
   }
}
