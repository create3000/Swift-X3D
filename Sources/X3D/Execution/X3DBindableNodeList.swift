//
//  X3DBindableNodeList.swift
//  X3D
//
//  Created by Holger Seelig on 24.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class X3DBindableList <Type : X3DBindableNode> :
   X3DBaseNode
{
   public private(set) final var list = Array <Type> ()
   private final var collected = Array <Type> ()
   private final var updateTime : TimeInterval = 0

   internal init (with executionContext : X3DExecutionContext, default node : Type)
   {
      super .init (executionContext .browser!, executionContext)
      
      list      .append (node)
      collected .append (node)
   }
   
   internal final func first (name : String? = nil) -> Type
   {
      guard list .count > 1 else { return list .first! }

      if name != nil && !name! .isEmpty
      {
         // Return first viewpoint with @name.

         for node in list [1...]
         {
            if node .scene !== scene
            {
               continue
            }

            if node .getName () == name
            {
               return node
            }
         }
      }

      // Return first bound viewpoint in scene.

      for node in list [1...]
      {
         if node .scene !== scene
         {
            continue
         }

         if node .isBound
         {
            return node
         }
      }

      // Return first viewpoint in scene.

      for node in list [1...]
      {
         if node .scene !== scene
         {
            continue
         }

         return node
      }
      
      return list .first!
   }
   
   internal final func append (node : Type)
   {
      collected .append (node)
   }
   
   internal final func update (with layer : X3DLayerNode, stack: X3DBindableStack <Type>)
   {
      // Determine currently changed nodes.
      
      let changedNodes = collected .filter ({ $0 .updateTime > updateTime })
      var removedNodes = [Type] ()
      
      // Swap lists if needed.
      
      if collected != list
      {
         // Unbind nodes not in current list (collected).
         
         let difference = collected .difference (from: list)
         
         for change in difference
         {
            switch change
            {
               case let .remove (_, oldNode, _):
                  removedNodes .append (oldNode)
               default:
                  break
            }
         }

         // Swap arrays.
         
         swap (&collected, &list)
         
         // Propagate change.
      
         addEvent ()
      }
      
      // Clear collected array.
      
      collected .removeSubrange (1...)
      
      // Update stack.
      
      stack .update (with: layer, removedNodes: removedNodes, changedNodes: changedNodes)
      
      // Advance update time.
      
      updateTime = Date () .timeIntervalSince1970
   }
}
