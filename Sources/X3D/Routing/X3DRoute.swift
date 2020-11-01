//
//  X3DRoute.swift
//  X3D
//
//  Created by Holger Seelig on 17.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DRoute :
   Equatable
{
   // Properties
   
   public private(set) final weak var sourceNode       : X3DNode?
   public private(set) final weak var sourceField      : X3DField?
   public private(set) final weak var destinationNode  : X3DNode?
   public private(set) final weak var destinationField : X3DField?

   // Construction

   internal init (_ sourceNode : X3DNode, _ sourceField : X3DField, _ destinationNode : X3DNode, _ destinationField : X3DField)
   {
      self .sourceNode       = sourceNode
      self .sourceField      = sourceField
      self .destinationNode  = destinationNode
      self .destinationField = destinationField

      connect ()
   }
   
   private final func connect ()
   {
      sourceField! .addFieldInterest (for: destinationField!)
   }
   
   // Comparision operators
   
   public static func == (lhs : X3DRoute, rhs : X3DRoute) -> Bool
   {
      return lhs === rhs
   }
}
