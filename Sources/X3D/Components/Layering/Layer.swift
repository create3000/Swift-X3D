//
//  Layer.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Layer :
   X3DLayerNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "Layer" }
   public final override class var component      : String { "Layering" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "layers" }

   // Fields

   @MFNode public final var addChildren    : MFNode <X3DNode> .Value
   @MFNode public final var removeChildren : MFNode <X3DNode> .Value
   @MFNode public final var children       : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      let group = Group (with: executionContext)
      
      super .init (browser: executionContext .browser!,
                   executionContext: executionContext,
                   viewpointNode: Viewpoint (with: executionContext),
                   groupNode: group)

      types .append (.Layer)

      addField (.inputOutput, "metadata",       $metadata)
      addField (.inputOutput, "isPickable",     $isPickable)
      addField (.inputOutput, "viewport",       $viewport)
      addField (.inputOnly,   "addChildren",    $addChildren)
      addField (.inputOnly,   "removeChildren", $removeChildren)
      addField (.inputOutput, "children",       $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Layer
   {
      return Layer (with: executionContext)
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
