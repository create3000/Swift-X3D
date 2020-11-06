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
   
   public final override class var typeName       : String { "OpacityMapVolumeStyle" }
   public final override class var component      : String { "VolumeRendering" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "renderStyle" }

   // Fields

   @SFNode public final var transferFunction : X3DNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
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
