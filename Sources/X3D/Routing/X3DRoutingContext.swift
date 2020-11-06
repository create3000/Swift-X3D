//
//  X3DRoutingContext.swift
//  X3D
//
//  Created by Holger Seelig on 13.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DRoutingContextProperties :
   X3DBaseNode
{
   // Properties
   
   fileprivate var taintedFields : [(X3DField, X3DEvent)] = [ ]
   fileprivate var taintedNodes  : [X3DBaseNode] = [ ]
   
   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
}

public protocol X3DRoutingContext : class
{
   var browser                  : X3DBrowser { get }
   var routingContextProperties : X3DRoutingContextProperties! { get }
}

public extension X3DRoutingContext
{
   internal func addTaintedField (field : X3DField, event : X3DEvent)
   {
      routingContextProperties .taintedFields .append ((field, event))
   }
   
   internal func addTaintedNode (node : X3DBaseNode)
   {
      routingContextProperties .taintedNodes .append (node)
   }
   
   internal func processEvents ()
   {
      repeat
      {
         // Process field events
         
         repeat
         {
            let taintedFields = routingContextProperties .taintedFields

            routingContextProperties .taintedFields = [ ]

            for (field, event) in taintedFields
            {
               field .processEvent (event)
            }
         }
         while !routingContextProperties .taintedFields .isEmpty

         // Process node events
         
         repeat
         {
            let taintedNodes = routingContextProperties .taintedNodes

            routingContextProperties .taintedNodes = [ ]

            for node in taintedNodes
            {
               node .processEvents ()
            }
         }
         while routingContextProperties .taintedFields .isEmpty && !routingContextProperties .taintedNodes .isEmpty
      }
      while !routingContextProperties .taintedFields .isEmpty
   }
}
