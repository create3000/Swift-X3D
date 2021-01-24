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
      self .executionContext = executionContext
      self .sourceNode       = sourceNode
      self .sourceField      = sourceField
      self .destinationNode  = destinationNode
      self .destinationField = destinationField
      
      super .init ()
      
      sourceNode      .deleted .addInterest ("deleted", X3DRoute .set_node, self)
      destinationNode .deleted .addInterest ("deleted", X3DRoute .set_node, self)

      connect ()
   }
   
   public private(set) final var isConnected = false
   
   private final func connect ()
   {
      guard !isConnected,
            let sourceField      = sourceField,
            let destinationField = destinationField
      else { return }
      
      isConnected = true

      sourceField .addFieldInterest (to: destinationField)
      
      sourceField      .outputRoutes .add (self)
      destinationField .inputRoutes  .add (self)
      
      sourceField      .routes_changed .processInterests ()
      destinationField .routes_changed .processInterests ()
   }
   
   internal final func disconnect ()
   {
      guard isConnected,
            let sourceField      = sourceField,
            let destinationField = destinationField
      else { return }
      
      isConnected = false
      
      sourceField .removeFieldInterest (to: destinationField)
      
      sourceField      .outputRoutes .remove (self)
      destinationField .inputRoutes  .remove (self)
      
      sourceField      .routes_changed .processInterests ()
      destinationField .routes_changed .processInterests ()
   }
   
   private final func set_node ()
   {
      executionContext? .deleteRoute (route: self)
   }
   
   // Input/Output
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      guard let sourceNodeName      = stream .getLocalName (sourceNode),
            let destinationNodeName = stream .getLocalName (destinationNode)
      else { return }
      
      guard let sourceField      = sourceField,
            let destinationField = destinationField
      else { return }

      stream += stream .Indent
      stream += "<ROUTE"
      stream += stream .Space
      stream += "fromNode='"
      stream += sourceNodeName .toXMLString ()
      stream += "'"
      stream += stream .Space
      stream += "fromField='"
      stream += sourceField .getName () .toXMLString ()

      if sourceField .getAccessType () == .inputOutput
      {
         stream += "_changed"
      }

      stream += "'"
      stream += stream .Space
      stream += "toNode='"
      stream += destinationNodeName .toXMLString ()
      stream += "'"
      stream += stream .Space
      stream += "toField='"

      if destinationField .getAccessType () == .inputOutput
      {
         stream += "set_"
      }

      stream += destinationField .getName () .toXMLString ()
      stream += "'"
      stream += "/>"
   }
   
   internal final override func toJSONStream (_ stream : X3DOutputStream)
   {
      guard let sourceNodeName      = stream .getLocalName (sourceNode),
            let destinationNodeName = stream .getLocalName (destinationNode)
      else { return }
      
      guard let sourceField      = sourceField,
            let destinationField = destinationField
      else { return }

      stream += "{"
      stream += stream .TidySpace
      stream += "\""
      stream += "ROUTE"
      stream += "\""
      stream += ":"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()
      stream += stream .Indent
      stream += "{"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()

      stream += stream .Indent
      stream += "\""
      stream += "@fromNode"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += sourceNodeName .toJSONString ()
      stream += "\""
      stream += ","
      stream += stream .TidyBreak

      stream += stream .Indent
      stream += "\""
      stream += "@fromField"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += sourceField .getName () .toJSONString ()

      if sourceField .getAccessType () == .inputOutput
      {
         stream += "_changed"
      }

      stream += "\""
      stream += ","
      stream += stream .TidyBreak

      stream += stream .Indent
      stream += "\""
      stream += "@toNode"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += destinationNodeName .toJSONString ()
      stream += "\""
      stream += ","
      stream += stream .TidyBreak

      stream += stream .Indent
      stream += "\""
      stream += "@toField"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      
      if destinationField .getAccessType () == .inputOutput
      {
         stream += "set_"
      }

      stream += destinationField .getName () .toJSONString ()
      stream += "\""
      stream += stream .TidyBreak

      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "}"
      stream += stream .TidyBreak
      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "}"
   }

   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      guard let sourceNodeName      = stream .getLocalName (sourceNode),
            let destinationNodeName = stream .getLocalName (destinationNode)
      else { return }

      guard let sourceField      = sourceField,
            let destinationField = destinationField
      else { return }

      stream += stream .Indent
      stream += "ROUTE"
      stream += " "
      stream += sourceNodeName
      stream += "."
      stream += sourceField .getName ()

      if sourceField .getAccessType () == .inputOutput
      {
         stream += "_changed"
      }

      stream += " "
      stream += "TO"
      stream += " "
      stream += destinationNodeName
      stream += "."

      if destinationField .getAccessType () == .inputOutput
      {
         stream += "set_"
      }

      stream += destinationField .getName ()
      stream += stream .Break
   }
}
