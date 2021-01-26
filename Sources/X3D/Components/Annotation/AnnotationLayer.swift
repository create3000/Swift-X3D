//
//  AnnotationLayer.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class AnnotationLayer :
   X3DLayerNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "AnnotationLayer" }
   internal final override class var component      : String { "Annotation" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @MFString public final var layoutPolicy : [String]
   @MFString public final var shownGroupID : [String]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      let viewpoint = Viewpoint (with: executionContext)
      let group     = Group (with: executionContext)
      
      super .init (browser: executionContext .browser!,
                   executionContext: executionContext,
                   viewpointNode: viewpoint,
                   groupNode: group)

      types .append (.AnnotationLayer)

      addField (.inputOutput, "metadata",     $metadata)
      addField (.inputOutput, "isPickable",   $isPickable)
      addField (.inputOutput, "layoutPolicy", $layoutPolicy)
      addField (.inputOutput, "shownGroupID", $shownGroupID)
      addField (.inputOutput, "viewport",     $viewport)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> AnnotationLayer
   {
      return AnnotationLayer (with: executionContext)
   }
}
