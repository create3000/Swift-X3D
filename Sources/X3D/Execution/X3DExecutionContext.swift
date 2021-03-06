//
//  X3DExecutionContext.swift
//  X3D
//
//  Created by Holger Seelig on 08.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public class X3DExecutionContext :
   X3DBaseNode
{
   // Common properties
   
   internal override class var typeName : String { "X3DExecutionContext" }
   
   // Properties
   
   public override var scene : X3DScene? { super .scene }
   
   @MFNode public final var rootNodes : [X3DNode?]
   
   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)
      
      types .append (.X3DExecutionContext)
      
      addChildObjects ($rootNodes,
                       $namedNodes_changed,
                       $importedNodes_changed,
                       $protos_changed,
                       $externprotos_changed,
                       $routes_changed)
      
      $rootNodes .setName ("rootNodes")
   }
   
   // Scene properties
   
   public func getEncoding () -> String { scene! .getEncoding () }
   
   internal func setEncoding (_ value : String) { scene! .setEncoding (value) }

   public func getSpecificationVersion () -> String { scene! .getSpecificationVersion () }
   
   internal func setSpecificationVersion (_ value : String) { scene! .setSpecificationVersion (value) }

   public func getCharacterEncoding () -> String { scene! .getCharacterEncoding () }

   internal func setCharacterEncoding (_ value : String) { scene! .setCharacterEncoding (value) }

   public func getComment () -> String { scene! .getComment () }

   internal func setComment (_ value : String) { scene! .setComment (value) }

   public func getWorldURL () -> URL { scene! .getWorldURL () }

   internal func setWorldURL (_ value : URL) { scene! .setWorldURL (value) }

   // Profile handling
   
   public func getProfile () -> ProfileInfo { scene! .getProfile () }
   
   public func setProfile (_ value : ProfileInfo) { scene! .setProfile (value) }
   
   // Components handling
   
   public func getComponents () -> [ComponentInfo] { scene! .getComponents () }
   
   public func setComponents (_ value : [ComponentInfo]) { scene! .setComponents (value) }
   
   public func addComponent (_ component : ComponentInfo) { scene! .addComponent (component) }
   
   private final weak var worldInfo : WorldInfo?
   
   internal final func setWorldInfo (_ node : WorldInfo)
   {
      worldInfo = node
   }
   
   public final func getWorldInfo (create : WorldInfo .Create? = nil) -> WorldInfo?
   {
      if let worldInfo = worldInfo
      {
         return worldInfo
      }
      else if let create = create
      {
         worldInfo = createNode (of: WorldInfo .self)
         
         worldInfo! .title = getWorldURL () .lastPathComponent
         
         switch create
         {
            case .First:
               rootNodes .insert (worldInfo, at: 0)
            case .Last:
               rootNodes .append (worldInfo)
         }
         
         return worldInfo
      }
      else
      {
         return nil
      }
   }

   // Node handling
   
   /// Creates a new node of type `Type`.
   /// * parameters:
   ///   * of: A supported node type.
   /// * returns: A node of type `Type`.
   public final func createNode <Type : X3DNode> (of type : Type .Type) -> Type
   {
      return try! createNode (typeName: Type .typeName, setup: true) as! Type
   }
   
   /// Creates a new node of type `typeName`.
   /// * parameters:
   ///   * typeName: A supported node type name.
   /// * throws:
   ///   * `INVALID_NAME`  if node of type `typeName` was not found.
   /// * returns: A node of type `typeName`.
   public final func createNode (typeName : String) throws -> X3DNode
   {
      return try createNode (typeName: typeName, setup: true)
   }
   
   internal final func createNode (typeName : String, setup : Bool) throws -> X3DNode
   {
      guard let node = SupportedNodes .nodes [typeName]? .init (with: self) else
      {
         throw X3DError .INVALID_NAME ("Unknown node type '\(typeName)'.")
      }

      if (setup) { node .setup () }
      
      return node
   }
   
   /// Creates a new prototype instance of type `typeName`.
   /// * parameters:
   ///   * typeName: An existing prototype name.
   ///   * setup: If true, the protoype instance will be setuped.
   /// * throws:
   ///   * `INVALID_NAME`  if proto named `typeName` was not found.
   /// * returns: A prototype instance of type `typeName`.
   public final func createProto (typeName : String) throws -> X3DPrototypeInstance
   {
      return try createProto (typeName: typeName, setup: true)
   }
   
   internal final func createProto (typeName : String, setup : Bool) throws -> X3DPrototypeInstance
   {
      let protoNode     = try findProtoDeclaration (name: typeName)
      let protoInstance = protoNode .createInstance (with: self, setup: setup)
      
      return protoInstance
   }
   
   public final func findProtoDeclaration (name : String) throws -> X3DProtoDeclarationNode
   {
      if let proto = try? getProtoDeclaration (name: name)
      {
         return proto
      }
      
      if let externproto = try? getExternProtoDeclaration (name: name)
      {
         return externproto
      }
      
      if self !== scene
      {
         return try executionContext! .findProtoDeclaration (name: name)
      }

      throw X3DError .INVALID_NAME (t("Unknown proto or externproto '%@'.", name))
   }
   
   // Named node handling
   
   private final var namedNodes : [String : X3DNamedNode] = [:]
   
   /// Returns the node with `name`.
   /// * parameters:
   ///   * name The name of the node to be returned.
   public final func getNamedNode (name : String) throws -> X3DNode
   {
      guard let namedNode = namedNodes [name] else
      {
         throw X3DError .INVALID_NAME (t("Named node '%@' not found.", name))
      }
      
      return namedNode .node!
   }
   
   /// Add a named node.
   public final func addNamedNode (name : String, node : X3DNode) throws
   {
      guard node .executionContext === self else
      {
         throw X3DError .INVALID_NODE (t("Couldn't add named node: node does not belong to this execution context."))
      }

      guard !name .isEmpty else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add named node: name is empty."))
      }
      
      guard namedNodes [name] == nil else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add named node: named node '%@' already exits.", name))
      }
      
      guard node .getName () .isEmpty else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add named node: node name not empty, is '%@'.", node .getName ()))
      }

      namedNodes [name] = X3DNamedNode (self, node, name)
      
      node .setName (name)
      
      namedNodes_changed = SFTime .now
   }
   
   /// Update the name for a node.
   public final func updateNamedNode (name : String, node : X3DNode) throws
   {
      guard node .executionContext === self else
      {
         throw X3DError .INVALID_NODE (t("Couldn't update named node: node does not belong to this execution context."))
      }

      guard !name .isEmpty else
      {
         throw X3DError .INVALID_NAME (t("Couldn't update named node: name is empty."))
      }
      
      if let oldNamedNode = namedNodes [name]
      {
         oldNamedNode .node? .setName ("")
      }

      namedNodes .removeValue (forKey: node .getName ())

      namedNodes [name] = X3DNamedNode (self, node, name)
      
      node .setName (name)
      
      namedNodes_changed = SFTime .now
   }
   
   /// Removes a named node or silently returns if a named node with`name` does not exists.
   public final func removeNamedNode (name : String)
   {
      guard let oldNamedNode = namedNodes .removeValue (forKey: name) else { return }
      
      oldNamedNode .node? .setName ("")
      
      namedNodes_changed = SFTime .now
   }
   
   public final func getNamedNodes () -> [String : X3DNamedNode] { namedNodes }
   
   @SFTime public final var namedNodes_changed = 0

   /// Return either an imported node or a named node with `localName`.
   internal final func getLocalNode (localName : String) throws -> X3DBaseNode
   {
      if let node = try? getNamedNode (name: localName)
      {
         return node
      }
      else
      {
         guard let importedNode = importedNodes [localName] else
         {
            throw X3DError .INVALID_NAME (t("Unknown named or imported node '%@'.", localName))
         }
         
         return importedNode
      }
   }
   
   private final func getLocalName (node : X3DNode) throws -> String
   {
      if node .executionContext === self
      {
         return node .getName ()
      }
      
      for (importedName, importedNode) in importedNodes
      {
         if let exportedNode = importedNode .exportedNode,
            exportedNode === node
         {
            return importedName
         }
      }

      throw X3DError .INVALID_NODE (t("Couldn't get local name: node is shared."))
   }
   
   /// Returns a name for a named node that is unique in this execution context.
   public final func getUniqueName (for name : String) -> String
   {
      let name       = remove_trailing_number (name)
      var uniqueName = name
      var i          = UInt (1)

      while namedNodes [uniqueName] != nil || uniqueName .isEmpty
      {
         i = i == 0 ? 1 : i
         
         let min = i
         let max = i << 1
         
         uniqueName  = name
         uniqueName += "_"
         uniqueName += String (UInt .random (in: min ..< max))

         i = max
      }

      return uniqueName
   }
   
   // Imported node handling
   
   private final var importedNodes = [String : X3DImportedNode] ()
   
   public final func getImportedNode (importedName : String) throws -> X3DNode
   {
      guard let importedNode = importedNodes [importedName] else
      {
         throw X3DError .INVALID_NAME (t("Imported node '%@' not found.", importedName))
      }

      guard let exportedNode = importedNode .exportedNode else
      {
         throw X3DError .INVALID_NAME (t("Exported node '%@' not found.", importedNode .exportedName))
      }
      
      return exportedNode
   }

   public final func addImportedNode (inlineNode : Inline, exportedName : String, importedName : String = "") throws
   {
      let importedName = importedName .isEmpty ? exportedName : importedName

      guard importedNodes [importedName] == nil else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add imported node: imported name '%@' already in use.", importedName))
      }
      
      try updateImportedNode (inlineNode: inlineNode, exportedName: exportedName, importedName: importedName)
   }
   
   public final func updateImportedNode (inlineNode : Inline, exportedName : String, importedName : String = "") throws
   {
      let importedName = importedName .isEmpty ? exportedName : importedName

      guard !exportedName .isEmpty else
      {
         throw X3DError .INVALID_NAME ("Couldn't update imported node: exported name is empty.")
      }

      guard !importedName .isEmpty else
      {
         throw X3DError .INVALID_NAME ("Couldn't update imported node: imported name is empty.")
      }
      
      // Update existing imported node.

      for (key, importedNode) in importedNodes
      {
         guard importedNode .inlineNode === inlineNode,
               importedNode .exportedName == exportedName
         else { continue }
         
         importedNodes .removeValue (forKey: key)

         importedNodes [importedName] = X3DImportedNode (self,
                                                         importedNode .inlineNode!,
                                                         importedNode .exportedName,
                                                         importedNode .importedName)

         
         importedNodes_changed = SFTime .now
         return
      }

      // Add new imported node.
      
      removeImportedNode (importedName: importedName)

      importedNodes [importedName] = X3DImportedNode (self,
                                                      inlineNode,
                                                      exportedName,
                                                      importedName)
      
      importedNodes_changed = SFTime .now
  }
   
   public final func removeImportedNode (importedName : String)
   {
      guard let importedNode = importedNodes .removeValue (forKey: importedName) else { return }
      
      importedNode .dispose ()
      
      importedNodes_changed = SFTime .now
   }
   
   public final func getImportedNodes () -> [X3DImportedNode]
   {
      importedNodes .map { (_, node) in node } .sorted { $0 .importedName < $1 .importedName }
   }
   
   @SFTime public final var importedNodes_changed = 0

   // Proto handling
   
   private final var protos = [X3DProtoDeclaration] ()
   
   public final func createProtoDeclaration (name : String, interfaceDeclarations : [X3DInterfaceDeclaration]) -> X3DProtoDeclaration
   {
      return createProtoDeclaration (name: name, interfaceDeclarations: interfaceDeclarations, setup: true)
   }
   
   internal final func createProtoDeclaration (name : String, interfaceDeclarations : [X3DInterfaceDeclaration], setup : Bool) -> X3DProtoDeclaration
   {
      let proto = X3DProtoDeclaration (executionContext: self)
      
      proto .setName (name)
      
      for interfaceDeclaration in interfaceDeclarations
      {
         proto .addUserDefinedField (interfaceDeclaration .accessType, interfaceDeclaration .name, interfaceDeclaration .field)
      }
      
      if setup
      {
         proto .setup ()
      }
      
      return proto
   }
   
   public final func addProtoDeclaration (name : String, proto : X3DProtoDeclaration) throws
   {
      guard !name .isEmpty else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add proto declaration: proto name is empty."))
      }
      
      guard !hasProtoDeclaration (name: name) else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add proto declaration: proto '%@' is already in use.", name))
      }
      
      proto .setName (name)
      
      protos .append (proto)
      
      protos_changed = SFTime .now
   }
   
   public final func updateProtoDeclaration (name : String, proto : X3DProtoDeclaration) throws
   {
      guard !name .isEmpty else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add proto declaration: proto name is empty."))
      }

      proto .setName (name)
      
      if !protos .contains (proto)
      {
         protos .append (proto)
         
         protos_changed = SFTime .now
      }
   }
   
   public final func removeProtoDeclaration (name : String)
   {
      protos .removeAll (where: { $0 .getName () == name })
      
      protos_changed = SFTime .now
   }
   
   public final func hasProtoDeclaration (name : String) -> Bool
   {
      return protos .contains (where: { $0 .getName () == name })
   }

   public final func getProtoDeclaration (name : String) throws -> X3DProtoDeclaration
   {
      guard let proto = protos .first (where: { $0 .getName () == name }) else
      {
         throw X3DError .INVALID_NAME (t("Proto declaration '%@' not found.", name))
      }
      
      return proto
   }
   
   public final func getProtoDeclarations () -> [X3DProtoDeclaration] { protos }
   
   @SFTime public final var protos_changed = 0
   
   /// Returns a name for a proto that is unique in this execution context.
   public final func getUniqueProtoName (for name : String) -> String
   {
      let name       = proto_remove_trailing_number (name)
      let names      = Set (protos .map { $0 .getName () })
      var uniqueName = name
      var i          = UInt (1)

      while names .contains (uniqueName) || uniqueName .isEmpty
      {
         i = i == 0 ? 1 : i
         
         let min = i
         let max = i << 1
         
         uniqueName  = name
         uniqueName += String (UInt .random (in: min ..< max))

         i = max
      }

      return uniqueName
   }

   // Extern proto handling
   
   private final var externprotos = [X3DExternProtoDeclaration] ()
   
   public final func createExternProtoDeclaration (name : String, interfaceDeclarations : [X3DInterfaceDeclaration], url : [String]) -> X3DExternProtoDeclaration
   {
      return createExternProtoDeclaration (name: name, interfaceDeclarations: interfaceDeclarations, url: url, setup: true)
   }

   internal final func createExternProtoDeclaration (name : String, interfaceDeclarations : [X3DInterfaceDeclaration], url : [String], setup : Bool) -> X3DExternProtoDeclaration
   {
      let externproto = X3DExternProtoDeclaration (executionContext: self, url: url)
      
      externproto .setName (name)
      
      for interfaceDeclaration in interfaceDeclarations
      {
         externproto .addUserDefinedField (interfaceDeclaration .accessType, interfaceDeclaration .name, interfaceDeclaration .field)
      }
      
      if setup
      {
         externproto .setup ()
      }
      
      return externproto
   }

   public final func addExternProtoDeclaration (name : String, externproto : X3DExternProtoDeclaration) throws
   {
      guard !name .isEmpty else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add extern proto declaration: extern proto name is empty."))
      }
      
      guard !hasExternProtoDeclaration (name: name) else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add extern proto declaration: extern proto '%@' is already in use.", name))
      }
      
      externproto .setName (name)
      
      externprotos .append (externproto)
      
      externprotos_changed = SFTime .now
   }

   public final func updateExternProtoDeclaration (name : String, externproto : X3DExternProtoDeclaration) throws
   {
      guard !name .isEmpty else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add extern proto declaration: extern proto name is empty."))
      }

      externproto .setName (name)
      
      if !externprotos .contains (externproto)
      {
         externprotos .append (externproto)
         
         externprotos_changed = SFTime .now
      }
   }

   public final func removeExternProtoDeclaration (name : String)
   {
      externprotos .removeAll (where: { $0 .getName () == name })
      
      externprotos_changed = SFTime .now
   }

   public final func hasExternProtoDeclaration (name : String) -> Bool
   {
      return externprotos .contains (where: { $0 .getName () == name })
   }

   public final func getExternProtoDeclaration (name : String) throws -> X3DExternProtoDeclaration
   {
      guard let externproto = externprotos .first (where: { $0 .getName () == name }) else
      {
         throw X3DError .INVALID_NAME (t("Extern proto declaration '%@' not found.", name))
      }
      
      return externproto
   }
   
   public final func getExternProtoDeclarations () -> [X3DExternProtoDeclaration] { externprotos }
   
   @SFTime public final var externprotos_changed = 0
   
   /// Returns a name for a proto that is unique in this execution context.
   public final func getUniqueExternProtoName (for name : String) -> String
   {
      let name       = proto_remove_trailing_number (name)
      let names      = Set (externprotos .map { $0 .getName () })
      var uniqueName = name
      var i          = UInt (1)

      while names .contains (uniqueName) || uniqueName .isEmpty
      {
         i = i == 0 ? 1 : i
         
         let min = i
         let max = i << 1
         
         uniqueName  = name
         uniqueName += String (UInt .random (in: min ..< max))

         i = max
      }

      return uniqueName
   }

   // Route handling
   
   private final var routes = [X3DRoute] ()
   
   @discardableResult
   public final func addRoute (sourceNode : X3DNode,
                               sourceField : String,
                               destinationNode : X3DNode,
                               destinationField : String) throws -> X3DRoute
   {
      return try addRoute (sourceNode: sourceNode,
                           sourceField: sourceField,
                           destinationNode: destinationNode,
                           destinationField: destinationField)!
   }
   
   @discardableResult
   internal final func addRoute (sourceNode : X3DBaseNode,
                                 sourceField : String,
                                 destinationNode : X3DBaseNode,
                                 destinationField : String) throws -> X3DRoute?
   {
      // Imported nodes handling.

      var importedSourceNode      : X3DBaseNode? = sourceNode      as? X3DImportedNode
      var importedDestinationNode : X3DBaseNode? = destinationNode as? X3DImportedNode

      do
      {
         // If sourceNode is shared node try to find the corresponding ImportedNode.
         if let sourceNode = sourceNode as? X3DNode,
            sourceNode .executionContext !== self
         {
            importedSourceNode = try getLocalNode (localName: getLocalName (node: sourceNode))
         }
      }
      catch
      {
         // Source node is shared but not imported.
      }
      
      do
      {
         // If sourceNode is shared node try to find the corresponding ImportedNode.
         if let destinationNode = destinationNode as? X3DNode,
            destinationNode .executionContext !== self
         {
            importedDestinationNode = try getLocalNode (localName: getLocalName (node: destinationNode))
         }
      }
      catch
      {
         // Destination node is shared but not imported.
      }
      
      if let importedSourceNode      = importedSourceNode      as? X3DImportedNode,
         let importedDestinationNode = importedDestinationNode as? X3DImportedNode
      {
         importedSourceNode .addRoute (sourceNode: importedSourceNode,
                                       sourceField: sourceField,
                                       destinationNode: importedDestinationNode,
                                       destinationField: destinationField)
         
         importedDestinationNode .addRoute (sourceNode: importedSourceNode,
                                            sourceField: sourceField,
                                            destinationNode: importedDestinationNode,
                                            destinationField: destinationField)
      }
      else if let importedSourceNode = importedSourceNode as? X3DImportedNode
      {
         importedSourceNode .addRoute (sourceNode: importedSourceNode,
                                       sourceField: sourceField,
                                       destinationNode: destinationNode,
                                       destinationField: destinationField)
      }
      else if let importedDestinationNode = importedDestinationNode as? X3DImportedNode
      {
         importedDestinationNode .addRoute (sourceNode: sourceNode,
                                            sourceField: sourceField,
                                            destinationNode: importedDestinationNode,
                                            destinationField: destinationField)
      }

      // If either sourceNode or destinationNode is an ImportedNode return here without value.
      if importedSourceNode === sourceNode || importedDestinationNode === destinationNode
      {
         return nil
      }

      // Create route and return.
      
      guard let sourceNode      = sourceNode      as? X3DNode,
            let destinationNode = destinationNode as? X3DNode
      else { throw X3DError .INVALID_NODE ("Source and destination node must be of type X3DNode.") }
      
      return try addSimpleRoute (sourceNode: sourceNode,
                                 sourceField: sourceField,
                                 destinationNode: destinationNode,
                                 destinationField: destinationField)
   }
      
   internal final func addSimpleRoute (sourceNode : X3DNode,
                                       sourceField : String,
                                       destinationNode : X3DNode,
                                       destinationField : String) throws -> X3DRoute
   {
      let sourceField      = try sourceNode      .getField (name: sourceField)
      let destinationField = try destinationNode .getField (name: destinationField)
      
      guard sourceField !== destinationField else
      {
         throw X3DError .INVALID_FIELD (t("Bad route specification: source field must not be equal to destination field."))
      }
      
      guard sourceField .isOutput else
      {
         throw X3DError .INVALID_ACCESS_TYPE (t("Bad route specification: source field must be an input."))
      }

      guard destinationField .isInput else
      {
         throw X3DError .INVALID_ACCESS_TYPE (t("Bad route specification: destination field must be an output."))
      }
      
      guard sourceField .getType () == destinationField .getType () else
      {
         throw X3DError .NOT_SUPPORTED (t("Bad route specification: source field and destination field must be of same type."))
      }
      
      // Find existing route.
      
      let index = routes .firstIndex (where:
      {
         route in route .sourceField === sourceField && route .destinationField === destinationField
      })
      
      guard index == nil else { return routes [index!] }

      // Append route.
      
      let route = X3DRoute (self, sourceNode, sourceField, destinationNode, destinationField)
      
      routes .append (route)
      
      routes_changed = SFTime .now

      return route
   }
 
   public final func deleteRoute (sourceNode : X3DNode,
                                  sourceField : String,
                                  destinationNode : X3DNode,
                                  destinationField : String)
   {
      // Remove route
      
      guard let sourceField      = try? sourceNode      .getField (name: sourceField)      else { return }
      guard let destinationField = try? destinationNode .getField (name: destinationField) else { return }
      
      guard let index = routes .firstIndex (where:
      {
         route in route .sourceField === sourceField && route .destinationField === destinationField
      })
      else { return }
      
      deleteImportedRoute (sourceNode: sourceNode,
                           destinationNode: destinationNode,
                           route: routes [index])

      routes .remove (at: index) .disconnect ()
      
      routes_changed = SFTime .now
  }

   public final func deleteRoute (route : X3DRoute)
   {
      guard let index = routes .firstIndex (of: route) else { return }
      
      deleteImportedRoute (sourceNode: route .sourceNode,
                           destinationNode: route .destinationNode,
                           route: route)
      
      routes .remove (at: index) .disconnect ()
      
      routes_changed = SFTime .now
   }

   internal final func deleteSimpleRoute (route : X3DRoute)
   {
      guard let index = routes .firstIndex (of: route) else { return }
      
      routes .remove (at: index) .disconnect ()
      
      routes_changed = SFTime .now
   }

   private final func deleteImportedRoute (sourceNode : X3DNode?,
                                           destinationNode : X3DNode?,
                                           route : X3DRoute)
   {
      // Imported nodes handling.

      var importedSourceNode      : X3DBaseNode? = nil
      var importedDestinationNode : X3DBaseNode? = nil

      do
      {
         // If sourceNode is shared node try to find the corresponding ImportedNode.
         if  let sourceNode = sourceNode,
             sourceNode .executionContext !== self
         {
            importedSourceNode = try getLocalNode (localName: getLocalName (node: sourceNode))
         }
      }
      catch
      {
         // Source node is shared but not imported.
      }
      
      do
      {
         // If sourceNode is shared node try to find the corresponding ImportedNode.
         if let destinationNode = destinationNode,
            destinationNode .executionContext !== self
         {
            importedDestinationNode = try getLocalNode (localName: getLocalName (node: destinationNode))
         }
      }
      catch
      {
         // Destination node is shared but not imported.
      }
      
      if let importedSourceNode      = importedSourceNode      as? X3DImportedNode,
         let importedDestinationNode = importedDestinationNode as? X3DImportedNode
      {
         importedSourceNode      .deleteRoute (route: route)
         importedDestinationNode .deleteRoute (route: route)
      }
      else if let importedSourceNode = importedSourceNode as? X3DImportedNode
      {
         importedSourceNode .deleteRoute (route: route)
      }
      else if let importedDestinationNode = importedDestinationNode as? X3DImportedNode
      {
         importedDestinationNode .deleteRoute (route: route)
      }
   }
   
   public final func getRoutes () -> [X3DRoute] { routes }
   
   @SFTime public final var routes_changed = 0

   // Input/Output
   
   internal override func toXMLStream (_ stream : X3DOutputStream)
   {
      // Enter stream.
      
      stream .push (self)
      stream .enterScope ()
      stream .setImportedNodes (importedNodes)
      
      // Output extern protos.
      
      for externproto in getExternProtoDeclarations ()
      {
         stream += stream .toXMLStream (externproto)
         stream += stream .TidyBreak
      }
      
      // Output protos.
      
      for proto in getProtoDeclarations ()
      {
         stream += stream .toXMLStream (proto)
         stream += stream .TidyBreak
      }

      // Output root nodes.
      
      if !rootNodes .isEmpty
      {
         stream += stream .toXMLStream ($rootNodes)
      }
      
      // Output imported nodes.
      
      for importedNode in getImportedNodes ()
      {
         stream += stream .toXMLStream (importedNode)
         stream += stream .TidyBreak
      }
      
      // Output protos.
      
      for route in getRoutes ()
      {
         stream += stream .toXMLStream (route)
         stream += stream .TidyBreak
      }

      // Leave stream.
      
      stream .leaveScope ()
      stream .pop (self)
   }
   
   internal override func toJSONStream (_ stream : X3DOutputStream)
   {
      // Enter stream.
      
      stream .push (self)
      stream .enterScope ()
      stream .setImportedNodes (importedNodes)
      
      // Extern proto declarations
      
      let externprotos = getExternProtoDeclarations ()

      if !externprotos .isEmpty
      {
         if stream .lastProperty
         {
            stream += ","
            stream += stream .TidyBreak
         }

         for i in 0 ..< externprotos .count
         {
            stream += stream .Indent
            stream += stream .toJSONStream (externprotos [i])

            if i != externprotos .count - 1
            {
               stream += ","
               stream += stream .TidyBreak
            }
         }

         stream .lastProperty = true
      }

      // Proto declarations
      
      let protos = getProtoDeclarations ()

      if !protos .isEmpty
      {
         if stream .lastProperty
         {
            stream += ","
            stream += stream .TidyBreak
         }

         for i in 0 ..< protos .count
         {
            stream += stream .Indent
            stream += stream .toJSONStream (protos [i])

            if i != protos .count - 1
            {
               stream += ","
               stream += stream .TidyBreak
            }
         }

         stream .lastProperty = true
      }
      
      // Root nodes

      if !rootNodes .isEmpty
      {
         if stream .lastProperty
         {
            stream += ","
            stream += stream .TidyBreak
         }

         for i in 0 ..< rootNodes .count
         {
            if let value = rootNodes [i]
            {
               stream += stream .Indent
               stream += stream .toJSONStream (value)
            }
            else
            {
               stream += stream .Indent
               stream += "null"
            }

            if i != rootNodes .count - 1
            {
               stream += ","
               stream += stream .TidyBreak
            }
         }

         stream .lastProperty = true
      }
      
      // Imported nodes

      let importedNodes = getImportedNodes () .map { stream .toJSONStream ($0, streaming: false) } .filter { !$0 .isEmpty }
      
      if !importedNodes .isEmpty
      {
         if stream .lastProperty
         {
            stream += ","
            stream += stream .TidyBreak
         }

         for i in 0 ..< importedNodes .count
         {
            stream += stream .Indent
            stream += importedNodes [i]

            if i != importedNodes .count - 1
            {
               stream += ","
               stream += stream .TidyBreak
            }
         }

         stream .lastProperty = true
      }

      // Routes

      let routes = getRoutes () .map { stream .toJSONStream ($0, streaming: false) } .filter { !$0 .isEmpty }
      
      if !routes .isEmpty
      {
         if stream .lastProperty
         {
            stream += ","
            stream += stream .TidyBreak
         }

         for i in 0 ..< routes .count
         {
            stream += stream .Indent
            stream += routes [i]

            if i != routes .count - 1
            {
               stream += ","
               stream += stream .TidyBreak
            }
         }

         stream .lastProperty = true
      }
      
      // Leave stream.
      
      stream .leaveScope ()
      stream .pop (self)
   }

   internal override func toVRMLStream (_ stream : X3DOutputStream)
   {
      // Enter stream.
      
      stream .push (self)
      stream .enterScope ()
      stream .setImportedNodes (importedNodes)
      
      // Output externprotos.
      
      let externprotos = getExternProtoDeclarations ()
      
      for externproto in externprotos
      {
         stream += stream .toVRMLStream (externproto)
         stream += stream .TidyBreak
         stream += stream .TidyBreak
      }
      
      // Output protos.
      
      let protos = getProtoDeclarations ()
      
      for proto in protos
      {
         stream += stream .toVRMLStream (proto)
         stream += stream .TidyBreak
         stream += stream .TidyBreak
      }

      // Output root nodes.
      
      for i in 0 ..< rootNodes .count
      {
         stream += stream .Indent
         
         if let rootNode = rootNodes [i]
         {
            let use = stream .existsNode (rootNode)
            
            stream += stream .toVRMLStream (rootNode)
            stream += use ? stream .Break : stream .TidyBreak
         }
         else
         {
            stream += "NULL"
            stream += stream .Break
         }
         
         if i != rootNodes .count - 1
         {
            stream += stream .TidyBreak
         }
      }
      
      // Output imported nodes.
      
      let importedNodes = getImportedNodes ()
      
      if !importedNodes .isEmpty
      {
         stream += stream .Break
         
         for importedNode in importedNodes
         {
            stream += stream .toVRMLStream (importedNode)
         }
      }
      
      // Output routes.
      
      let routes = getRoutes ()
      
      if !routes .isEmpty
      {
         stream += stream .Break

         for route in routes
         {
            stream += stream .toVRMLStream (route)
         }
      }
      
      // Leave stream.
      
      stream .leaveScope ()
      stream .pop (self)
   }
}
