//
//  X3DBindableStack.swift
//  X3D
//
//  Created by Holger Seelig on 24.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DBindableStack <Type : X3DBindableNode> :
   X3DBaseNode
{
   internal final var top : Type { stack .last! }
   private final var stack = Array <Type> ()
   
   internal init (with executionContext : X3DExecutionContext, default node : Type)
   {
      super .init (executionContext .browser!, executionContext)
      
      stack .append (node)
   }
   
   internal final func pushOnTop (node : Type)
   {
      if node !== stack .first!
      {
         stack .last! .isBound = false
         stack .append (node)
      }
      
      node .isBound  = true
      node .bindTime = browser! .currentTime
      
      addEvent ()
   }
   
   internal final func update (with layer : X3DLayerNode, removedNodes : [Type], changedNodes : [Type])
   {
      if removedNodes .isEmpty && changedNodes .isEmpty { return }
      
      // Save top node for later use.
      
      let boundNode = stack .last!
      
      // Remove invisible nodes and unbind them if needed.
      
      for removedNode in removedNodes
      {
         if let index = stack .firstIndex (of: removedNode)
         {
            stack .remove (at: index)
         }
         
         if removedNode .isBound
         {
            removedNode .isBound = false
         }
      }
      
      // Unbind nodes with set_bind false and pop top node.
      
      let unbindNodes = changedNodes .filter ({ !$0 .set_bind })
      
      for unbindNode in unbindNodes
      {
         unbindNode .isBound = false
      }
      
      if unbindNodes .contains (boundNode)
      {
         stack .removeLast ()
      }
      
      // Push nodes with set_bind true to top of stack.
      
      for bindNode in changedNodes .filter ({ $0 .set_bind })
      {
         if let index = stack .firstIndex (of: bindNode)
         {
            stack .remove (at: index)
         }
         
         stack .append (bindNode)
      }
      
      // Bind top node if not bound.
      
      if !stack .last! .isBound
      {
         // Bound node could be the default node, and this node must be unbound here.
         boundNode .isBound = false
         
         stack .last! .isBound  = true
         stack .last! .bindTime = browser! .currentTime
         
         stack .last! .transitionStart (with: layer, from: boundNode)
         
         addEvent ()
      }
   }
}
