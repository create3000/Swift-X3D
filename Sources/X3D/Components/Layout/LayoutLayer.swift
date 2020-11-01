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
   
   public final override class var typeName       : String { "LayoutLayer" }
   public final override class var component      : String { "Layout" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "layers" }

   // Fields

   @SFNode public final var layout         : X3DNode?
   @MFNode public final var addChildren    : MFNode <X3DNode> .Value
   @MFNode public final var removeChildren : MFNode <X3DNode> .Value
   @MFNode public final var children       : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
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
      
      $addChildren    .addFieldInterest (for: groupNode! .$addChildren)
      $removeChildren .addFieldInterest (for: groupNode! .$removeChildren)
      $children       .addFieldInterest (for: groupNode! .$children)
      
      groupNode! .children .append (contentsOf: children)
      
      groupNode! .setup ()
   }
}
