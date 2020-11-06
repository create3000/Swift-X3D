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
   
   public final override class var typeName       : String { "SegmentedVolumeData" }
   public final override class var component      : String { "VolumeRendering" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @MFBool public final var segmentEnabled     : MFBool .Value
   @SFNode public final var segmentIdentifiers : X3DNode?
   @MFNode public final var renderStyle        : MFNode <X3DNode> .Value
   @SFNode public final var voxels             : X3DNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
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
