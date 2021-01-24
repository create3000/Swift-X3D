//
//  File.swift
//  
//
//  Created by Holger Seelig on 18.01.21.
//

public final class X3DImportedNode :
   X3DBaseNode
{
   // Common properties
   
   internal final override class var typeName : String { "X3DImportedNode" }
   
   // Properties
   
   public private(set) final weak var inlineNode : Inline?
   public final let exportedName                 : String
   public final let importedName                 : String
   
   // Construction
   
   internal init (_ executionContext : X3DExecutionContext,
                  _ inlineNode : Inline,
                  _ exportedName : String,
                  _ importedName : String)
   {
      self .inlineNode   = inlineNode
      self .exportedName = exportedName
      self .importedName = importedName
      
      super .init (executionContext .browser!, executionContext)
 
      inlineNode .loadState .addInterest ("set_loadState", X3DImportedNode .set_loadState,  self)
      inlineNode .deleted   .addInterest ("deleted",       X3DImportedNode .set_inlineNode, self)

      set_loadState ()
  }
   
   // Exported node handling
   
   public final var exportedNode : X3DNode?
   {
      try? inlineNode? .internalScene? .getExportedNode (exportedName: exportedName)
   }
   
   private final var routes = Set <UnresolvedRoute> ()
   
   internal final func addRoute (sourceNode : X3DBaseNode,
                                 sourceField : String,
                                 destinationNode : X3DBaseNode,
                                 destinationField : String)
   {
      // Add route.
      
      let route = UnresolvedRoute (sourceNode, sourceField, destinationNode, destinationField)
      
      routes .insert (route)

      // Try to resolve source or destination node routes.

      if inlineNode? .checkLoadState == .COMPLETE_STATE
      {
         resolveRoute (route)
      }
   }
   
   private final func resolveRoute (_ route : UnresolvedRoute)
   {
      var sourceNode              = route .sourceNode      as? X3DNode
      var destinationNode         = route .destinationNode as? X3DNode
      let importedSourceNode      = route .sourceNode      as? X3DImportedNode
      let importedDestinationNode = route .destinationNode as? X3DImportedNode
      
      if let importedSourceNode = importedSourceNode
      {
         sourceNode = importedSourceNode .exportedNode
      }

      if let importedDestinationNode = importedDestinationNode
      {
         destinationNode = importedDestinationNode .exportedNode
      }
      
      if let sourceNode      = sourceNode,
         let destinationNode = destinationNode
      {
         route .route = try? executionContext! .addSimpleRoute (sourceNode: sourceNode,
                                                                sourceField: route .sourceField,
                                                                destinationNode: destinationNode,
                                                                destinationField: route .destinationField)
      }
   }
   
   internal final func deleteRoute (route : X3DRoute)
   {
      // Delete route.
      
      if let route = routes .first (where: { $0 .route === route })
      {
         routes .remove (route)
      }
   }

   private final func deleteRoutes ()
   {
      for route in routes
      {
         guard let realRoute = route .route else { continue }
         
         route .route = nil
         
         executionContext? .deleteSimpleRoute (route: realRoute)
      }
   }
   
   private final func set_loadState ()
   {
      switch inlineNode! .checkLoadState
      {
         case .NOT_STARTED_STATE: fallthrough
         case .FAILED_STATE: do
         {
            deleteRoutes ()
         }
         case .IN_PROGRESS_STATE:
            break
         case .COMPLETE_STATE: do
         {
            deleteRoutes ()

            for route in routes
            {
               resolveRoute (route)
            }
         }
      }
   }
   
   private final func set_inlineNode ()
   {
      executionContext? .removeImportedNode (importedName: importedName)
   }
   
   // Input/Output
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      guard let inlineNode = inlineNode,
            stream .existsNode (inlineNode) else { return }
      
      stream += stream .Indent
      stream += "<IMPORT"
      stream += stream .Space
      stream += "inlineDEF='"
      stream += stream .getName (inlineNode) .toXMLString ()
      stream += "'"
      stream += stream .Space
      stream += "importedDEF='"
      stream += exportedName .toXMLString ()
      stream += "'"

      if importedName != exportedName
      {
         stream += stream .Space
         stream += "AS='"
         stream += importedName .toXMLString ()
         stream += "'"
      }

      stream += "/>"

      stream .addRouteNode (self)
      
      // Output unresolved routes.
      
      if let exportedNode = exportedNode
      {
         stream .addImportedNode (exportedNode, importedName)
      }
      else
      {
         for route in routes
         {
            guard let sourceNode      = route .sourceNode,
                  let destinationNode = route .destinationNode
            else { continue }
            
            let sourceField      = route .sourceField
            let destinationField = route .destinationField

            guard stream .existsRouteNode (sourceNode) && stream .existsRouteNode (destinationNode) else { continue }
            
            let importedSourceNode      = sourceNode      as? X3DImportedNode
            let importedDestinationNode = destinationNode as? X3DImportedNode

            let sourceNodeName = importedSourceNode != nil
               ? importedSourceNode! .importedName
               : stream .getName (sourceNode as! X3DNode)
            
            let destinationNodeName = importedDestinationNode != nil
               ? importedDestinationNode! .importedName
               : stream .getName (destinationNode as! X3DNode)
               
            stream += stream .TidyBreak
            stream += stream .Indent
            stream += "<ROUTE"
            stream += stream .Space
            stream += "fromNode='"
            stream += sourceNodeName .toXMLString ()
            stream += "'"
            stream += stream .Space
            stream += "fromField='"
            stream += sourceField .toXMLString ()
            stream += "'"
            stream += stream .Space
            stream += "toNode='"
            stream += destinationNodeName .toXMLString ()
            stream += "'"
            stream += stream .Space
            stream += "toField='"
            stream += destinationField .toXMLString ()
            stream += "'"
            stream += "/>"
         }
      }
   }
   
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      guard let inlineNode = inlineNode,
            stream .existsNode (inlineNode) else { return }
      
      stream += stream .Indent
      stream += "IMPORT"
      stream += stream .Space
      stream += stream .getName (inlineNode)
      stream += "."
      stream += exportedName

      if importedName != exportedName
      {
         stream += stream .Space
         stream += "AS"
         stream += stream .Space
         stream += importedName
      }
      
      stream += stream .Break
      
      stream .addRouteNode (self)
      
      // Output unresolved routes.
      
      if let exportedNode = exportedNode
      {
         stream .addImportedNode (exportedNode, importedName)
      }
      else
      {
         for route in routes
         {
            guard let sourceNode      = route .sourceNode,
                  let destinationNode = route .destinationNode
            else { continue }
            
            let sourceField      = route .sourceField
            let destinationField = route .destinationField

            guard stream .existsRouteNode (sourceNode) && stream .existsRouteNode (destinationNode) else { continue }
            
            let importedSourceNode      = sourceNode      as? X3DImportedNode
            let importedDestinationNode = destinationNode as? X3DImportedNode

            let sourceNodeName = importedSourceNode != nil
               ? importedSourceNode! .importedName
               : stream .getName (sourceNode as! X3DNode)
            
            let destinationNodeName = importedDestinationNode != nil
               ? importedDestinationNode! .importedName
               : stream .getName (destinationNode as! X3DNode)

            stream += stream .Indent
            stream += "ROUTE"
            stream += stream .Space
            stream += sourceNodeName
            stream += "."
            stream += sourceField
            stream += stream .Space
            stream += "TO"
            stream += stream .Space
            stream += destinationNodeName
            stream += "."
            stream += destinationField
            stream += stream .Break
         }
      }
   }
   
   // Destruction
   
   internal final func dispose ()
   {
      deleteRoutes ()
   }
}

fileprivate class UnresolvedRoute :
   Hashable
{
   fileprivate final weak var sourceNode      : X3DBaseNode?
   fileprivate final let sourceField          : String
   fileprivate final weak var destinationNode : X3DBaseNode?
   fileprivate final let destinationField     : String
   fileprivate final var route                : X3DRoute?
   
   init (_ sourceNode : X3DBaseNode,
         _ sourceField : String,
         _ destinationNode : X3DBaseNode,
         _ destinationField : String)
   {
      self .sourceNode       = sourceNode
      self .sourceField      = sourceField
      self .destinationNode  = destinationNode
      self .destinationField = destinationField
   }
   
   static func == (lhs : UnresolvedRoute, rhs: UnresolvedRoute) -> Bool
   {
      return lhs .sourceNode       === rhs .sourceNode &&
             lhs .sourceField      ==  rhs .sourceField &&
             lhs .destinationNode  === rhs .destinationNode &&
             lhs .destinationField ==  rhs .destinationField
   }
   
   public final func hash (into hasher: inout Hasher)
   {
      hasher .combine (sourceNode)
      hasher .combine (sourceField)
      hasher .combine (destinationNode)
      hasher .combine (destinationField)
   }
}
