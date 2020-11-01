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
   
   public final override class var typeName       : String { "ComposedVolumeStyle" }
   public final override class var component      : String { "VolumeRendering" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "renderStyle" }

   // Fields

   @MFNode public final var renderStyle : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
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
