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
   
   private final var defaultLayerSetNode                 : LayerSet
   @SFNode public private(set) final var layerSetNode    : LayerSet?
   @SFNode public private(set) final var activeLayerNode : X3DLayerNode?
   
   // Construction
   
   internal init (with scene : X3DScene)
   {
      self .defaultLayerSetNode = LayerSet (with: scene)

      super .init (scene .browser!, scene)
      
      types .append (.X3DWorld)
      
      addChildObjects ($layerSetNode,
                       $activeLayerNode)

      setup ()
   }
   
   internal override func initialize ()
   {
      super .initialize ()

      executionContext! .$rootNodes .addInterest ("set_rootNodes", { $0 .set_rootNodes () }, self)

      set_rootNodes ()
      
      defaultLayerSetNode .setup ()

      activeLayerNode = layerSetNode! .activeLayerNode

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
         layerSetNode = defaultLayerSetNode
      }
      
      if layerSetNode !== oldLayerSetNode
      {
         // Handle root nodes.
         
         if oldLayerSetNode != nil
         {
            executionContext! .$rootNodes .removeFieldInterest (to: oldLayerSetNode! .layerNode0 .$children)
            oldLayerSetNode! .layerNode0 .children .removeAll ()
         }
         
         // Handle layer 0
         
         executionContext! .$rootNodes .addFieldInterest (to: layerSetNode! .layerNode0 .$children)
         
         layerSetNode! .layerNode0 .children = executionContext! .rootNodes

         // Handle active layer.
         
         oldLayerSetNode? .$activeLayerNode .removeFieldInterest (to: $activeLayerNode)
         layerSetNode!    .$activeLayerNode .addFieldInterest (to: $activeLayerNode)

         activeLayerNode = layerSetNode! .activeLayerNode
      }
   }

   // Rendering
   
   internal final func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      layerSetNode! .traverse (type, renderer)
   }

   // Desctruction
   
   deinit
   {
      #if DEBUG
      //debugPrint (#file, #function)
      #endif
   }
}
