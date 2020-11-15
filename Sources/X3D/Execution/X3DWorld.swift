//
//  X3DWorld.swift
//  X3D
//
//  Created by Holger Seelig on 08.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public final class X3DWorld :
   X3DBaseNode
{
   // Common properties
   
   internal final override class var typeName : String { "X3DWorld" }
   
   // Properties
   
   @SFNode private final var defaultLayerSetNode : LayerSet?
   @SFNode public private(set) final var layerSetNode : LayerSet?
   @SFNode public private(set) final var activeLayerNode : X3DLayerNode?
   
   // Construction
   
   internal init (with scene : X3DScene)
   {
      super .init (scene .browser!, scene)
      
      types .append (.X3DWorld)
      
      addChildObjects ($defaultLayerSetNode,
                       $layerSetNode,
                       $activeLayerNode)

      setup ()
   }
   
   internal override func initialize ()
   {
      super .initialize ()

      executionContext! .$rootNodes .addInterest ("set_rootNodes", X3DWorld .set_rootNodes, self)

      set_rootNodes ()

      layerSetNode! .bindFirstBindables ()
   }
   
   // Event handlers
   
   private final func set_rootNodes ()
   {
      let oldLayerSetNode = layerSetNode

      if let index = executionContext! .rootNodes .lastIndex (where: { $0 is LayerSet })
      {
         layerSetNode = executionContext! .rootNodes [index] as? LayerSet
      }
      else
      {
         if defaultLayerSetNode == nil
         {
            defaultLayerSetNode = LayerSet (with: executionContext!)
            defaultLayerSetNode! .setup ()
         }
         
         layerSetNode = defaultLayerSetNode
      }
      
      if layerSetNode !== oldLayerSetNode
      {
         // Handle root nodes.
         
         if oldLayerSetNode != nil
         {
            executionContext! .$rootNodes .removeFieldInterest (to: oldLayerSetNode! .layerNode0! .$children)
            oldLayerSetNode! .layerNode0! .children .removeAll ()
         }
         
         executionContext! .$rootNodes .addFieldInterest (to: layerSetNode! .layerNode0! .$children)
         layerSetNode! .layerNode0! .children .append (contentsOf: executionContext! .rootNodes)
         layerSetNode! .layerNode0! .setup ()

         // Handle active layer.
         
         oldLayerSetNode? .$activeLayer .removeFieldInterest (to: $activeLayerNode)
         layerSetNode!    .$activeLayer .addFieldInterest (to: $activeLayerNode)

         activeLayerNode = layerSetNode! .activeLayerNode
      }
   }

   // Rendering
   
   internal final func traverse (_ type : X3DTraverseType, _ renderer : X3DRenderer)
   {
      layerSetNode! .traverse (type, renderer)
   }

   // Desctruction
   
   deinit
   {
      debugPrint (#file, #function)
   }
}
