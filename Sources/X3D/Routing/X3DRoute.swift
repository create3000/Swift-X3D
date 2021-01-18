//
//  X3DRoute.swift
//  X3D
//
//  Created by Holger Seelig on 17.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DRoute :
   X3DObject
{
   // Common properties
   
   internal final override class var typeName : String { "X3DRoute" }
   
   // Properties
   
   public private(set) final weak var executionContext : X3DExecutionContext?
   public private(set) final weak var sourceNode       : X3DNode?
   public private(set) final weak var sourceField      : X3DField?
   public private(set) final weak var destinationNode  : X3DNode?
   public private(set) final weak var destinationField : X3DField?

   // Construction

   internal init (_ executionContext : X3DExecutionContext,
                  _ sourceNode : X3DNode,
                  _ sourceField : X3DField,
                  _ destinationNode : X3DNode,
                  _ destinationField : X3DField)
   {
      super .init ()
      
      self .executionContext = executionContext
      self .sourceNode       = sourceNode
      self .sourceField      = sourceField
      self .destinationNode  = destinationNode
      self .destinationField = destinationField

      connect ()
   }
   
   private final func connect ()
   {
      guard let sourceField      = sourceField,
            let destinationField = destinationField else { return }
      
      sourceField .addFieldInterest (to: destinationField)
      
      sourceField      .outputRoutes .add (self)
      destinationField .inputRoutes  .add (self)
      
      sourceField      .routes_changed .processInterests ()
      destinationField .routes_changed .processInterests ()
   }
   
   internal final func disconnect ()
   {
      guard let sourceField      = sourceField,
            let destinationField = destinationField else { return }
      
      sourceField .removeFieldInterest (to: destinationField)
      
      sourceField      .outputRoutes .remove (self)
      destinationField .inputRoutes  .remove (self)
      
      sourceField      .routes_changed .processInterests ()
      destinationField .routes_changed .processInterests ()
   }
   
   // Input/Output
   
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      guard let sourceNodeName      = stream .getLocalName (sourceNode),
            let destinationNodeName = stream .getLocalName (destinationNode)
      else { return }

      stream += stream .Indent
      stream += "ROUTE"
      stream += " "
      stream += sourceNodeName
      stream += "."
      stream += sourceField! .getName ()

      if sourceField! .getAccessType () == .inputOutput
      {
         stream += "_changed"
      }

      stream += " "
      stream += "TO"
      stream += " "
      stream += destinationNodeName
      stream += "."

      if destinationField! .getAccessType () == .inputOutput
      {
         stream += "set_"
      }

      stream += destinationField! .getName ()
      stream += stream .Break
   }
   
   // Destruction
   
   deinit
   {
      disconnect ()
   }
}
