//
//  LayoutLayer.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class LayoutLayer :
   X3DLayerNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "LayoutLayer" }
   internal final override class var component      : String { "Layout" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFNode public final var layout         : X3DNode?
   @MFNode public final var addChildren    : [X3DNode?]
   @MFNode public final var removeChildren : [X3DNode?]
   @MFNode public final var children       : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      let viewpointNode = OrthoViewpoint (with: executionContext)
      let groupNode     = LayoutGroup (with: executionContext)
      
      super .init (browser: executionContext .browser!,
                   executionContext: executionContext,
                   viewpointNode: viewpointNode,
                   groupNode: groupNode)

      types .append (.LayoutLayer)

      addField (.inputOutput, "metadata",       $metadata)
      addField (.inputOutput, "isPickable",     $isPickable)
      addField (.inputOutput, "layout",         $layout)
      addField (.inputOutput, "viewport",       $viewport)
      addField (.inputOnly,   "addChildren",    $addChildren)
      addField (.inputOnly,   "removeChildren", $removeChildren)
      addField (.inputOutput, "children",       $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> LayoutLayer
   {
      return LayoutLayer (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $addChildren    .addFieldInterest (to: groupNode .$addChildren)
      $removeChildren .addFieldInterest (to: groupNode .$removeChildren)
      $children       .addFieldInterest (to: groupNode .$children)
      
      groupNode .children = children
      
      groupNode .setup ()
   }
}
