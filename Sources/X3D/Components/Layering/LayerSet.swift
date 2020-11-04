//
//  LayerSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public final class LayerSet :
   X3DNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "LayerSet" }
   public final override class var component      : String { "Layering" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFInt32 public final var activeLayer : Int32 = 0
   @MFInt32 public final var order       : MFInt32 .Value = [0]
   @MFNode  public final var layers      : MFNode <X3DNode> .Value
   
   // Properties
   
   @SFNode internal private(set) final var activeLayerNode : X3DLayerNode?
   @SFNode internal private(set) final var layerNode0 : Layer?
   @MFNode private final var layerNodes : MFNode <X3DLayerNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      layerNode0 = Layer (with: executionContext)
      
      super .init (executionContext .browser!, executionContext)
      
      types .append (.LayerSet)

      addField (.inputOutput, "metadata",    $metadata)
      addField (.inputOutput, "activeLayer", $activeLayer)
      addField (.inputOutput, "order",       $order)
      addField (.inputOutput, "layers",      $layers)
      
      addChildObjects ($activeLayerNode,
                       $layerNode0,
                       $layerNodes)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> LayerSet
   {
      return LayerSet (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      layerNode0! .isPrivate = true
      layerNode0! .isLayer0  = true
      layerNode0! .setup ()
      
      $activeLayer .addInterest (LayerSet .set_activeLayer, self)
      $order       .addInterest (LayerSet .set_layers,      self)
      $layers      .addInterest (LayerSet .set_layers,      self)
      
      set_layers ()
   }
   
   ///  Bind first viewpoint and other bindables found.
   internal final func bindFirstBindables ()
   {
      layerNode0! .bindFirstBindables ()

      for layer in layers
      {
         guard let layerNode = layer? .innerNode as? X3DLayerNode else { continue }

         layerNode .bindFirstBindables ()
      }
   }

   // Event handlers
   
   private final func set_activeLayer ()
   {
      if (activeLayer == 0)
      {
         activeLayerNode = layerNode0
      }
      else
      {
         let index = activeLayer - 1

         if index >= 0 && index < layers .count
         {
            activeLayerNode = layers [index]? .innerNode as? X3DLayerNode
         }
         else
         {
            activeLayerNode = nil
         }
      }
   }
   
   private final func set_layers ()
   {
      layerNodes .removeAll ()

      for var index in order
      {
         if index == 0
         {
            layerNodes .append (layerNode0)
         }
         else
         {
            index -= 1

            if index >= 0 && index < layers .count
            {
               guard let layerNode = layers [index]? .innerNode as? X3DLayerNode else { continue }

               layerNodes .append (layerNode)
            }
         }
      }

      set_activeLayer ()
   }
   
   // Rendering
   
   internal final func traverse (_ type : X3DTraverseType, _ renderer : X3DRenderer)
   {
      renderer .layerNumber = 0

      for layerNode in layerNodes
      {
         layerNode! .traverse (type, renderer)
         
         renderer .layerNumber += 1
      }
   }
}