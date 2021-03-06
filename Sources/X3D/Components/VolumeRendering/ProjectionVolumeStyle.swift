//
//  ProjectionVolumeStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ProjectionVolumeStyle :
   X3DVolumeRenderStyleNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ProjectionVolumeStyle" }
   internal final override class var component      : String { "VolumeRendering" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "renderStyle" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFString public final var type               : String = "MAX"
   @SFFloat  public final var intensityThreshold : Float = 0

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ProjectionVolumeStyle)

      addField (.inputOutput, "metadata",           $metadata)
      addField (.inputOutput, "enabled",            $enabled)
      addField (.inputOutput, "type",               $type)
      addField (.inputOutput, "intensityThreshold", $intensityThreshold)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ProjectionVolumeStyle
   {
      return ProjectionVolumeStyle (with: executionContext)
   }
}
