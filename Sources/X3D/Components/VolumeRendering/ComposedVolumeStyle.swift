//
//  ComposedVolumeStyle.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ComposedVolumeStyle :
   X3DComposableVolumeRenderStyleNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ComposedVolumeStyle" }
   internal final override class var component      : String { "VolumeRendering" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "renderStyle" }

   // Fields

   @MFNode public final var renderStyle : [X3DNode?]

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ComposedVolumeStyle)

      addField (.inputOutput, "enabled", $enabled)
      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "renderStyle", $renderStyle)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ComposedVolumeStyle
   {
      return ComposedVolumeStyle (with: executionContext)
   }
}
