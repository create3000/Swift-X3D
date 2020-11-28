//
//  SegmentedVolumeData.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class SegmentedVolumeData :
   X3DVolumeDataNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "SegmentedVolumeData" }
   internal final override class var component      : String { "VolumeRendering" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }

   // Fields

   @MFBool public final var segmentEnabled     : [Bool]
   @SFNode public final var segmentIdentifiers : X3DNode?
   @MFNode public final var renderStyle        : [X3DNode?]
   @SFNode public final var voxels             : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.SegmentedVolumeData)

      addField (.inputOutput,    "metadata",           $metadata)
      addField (.inputOutput,    "dimensions",         $dimensions)
      addField (.inputOutput,    "segmentEnabled",     $segmentEnabled)
      addField (.initializeOnly, "bboxCenter",         $bboxCenter)
      addField (.initializeOnly, "bboxSize",           $bboxSize)
      addField (.inputOutput,    "segmentIdentifiers", $segmentIdentifiers)
      addField (.inputOutput,    "renderStyle",        $renderStyle)
      addField (.inputOutput,    "voxels",             $voxels)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> SegmentedVolumeData
   {
      return SegmentedVolumeData (with: executionContext)
   }
}
