//
//  OpacityMapVolumeStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class OpacityMapVolumeStyle :
   X3DComposableVolumeRenderStyleNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "OpacityMapVolumeStyle" }
   internal final override class var component      : String { "VolumeRendering" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "renderStyle" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFNode public final var transferFunction : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.OpacityMapVolumeStyle)

      addField (.inputOutput, "metadata",         $metadata)
      addField (.inputOutput, "enabled",          $enabled)
      addField (.inputOutput, "transferFunction", $transferFunction)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> OpacityMapVolumeStyle
   {
      return OpacityMapVolumeStyle (with: executionContext)
   }
}
