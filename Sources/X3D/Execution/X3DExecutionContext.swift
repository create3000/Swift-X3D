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
   
   @MFNode public final var rootNodes : MFNode <X3DNode> .Value
   
   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)
      
      types .append (.X3DExecutionContext)
      
      addChildObjects ($rootNodes)
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

   // Configuration handling
   
   public var profile    : X3DProfileInfo        { scene! .profile }
   public var components : X3DComponentInfoArray { scene! .components }
   
   // Unit handling
   
   public var units : X3DUnitInfoArray { scene! .units }

   public func updateUnit (_ category : X3DUnitCategory, name : String, conversionFactor : Double)
   {
      scene! .updateUnit (category, name: name, conversionFactor: conversionFactor)
   }
   
   public func fromUnit (_ category : X3DUnitCategory, value : Double) -> Double
   {
      return scene! .fromUnit (category, value: value)
   }
   
   public func toUnit (_ unit : X3DUnitCategory, value : Double) -> Double
   {
      return scene! .toUnit (unit, value: value)
   }
   
   // Metadata handling
   
   public var metadata : [String : [String]] { scene! .metadata }

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

      namedNodes [name] = X3DNamedNode (node)

      node .setName (name)
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

      namedNodes [name] = X3DNamedNode (node)
      
      node .setName (name)
   }
   
   /// Removes a named node or silently returns if a named node with`name` does not exists.
   public final func removeNamedNode (name : String)
   {
      guard let oldNamedNode = namedNodes .removeValue (forKey: name) else { return }
      
      oldNamedNode .node? .setName ("")
   }

   /// Return either an imported node or a named node with `localName`.
   internal final func getLocalNode (localName : String) throws -> X3DNode
   {
      return try getNamedNode (name: localName)
   }
   
   /// Returns a name for a named node that is unique in this execution context.
   public final func getUniqueName (for name: String) -> String
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
   
   public final func getImportedNode (importedName : String) throws -> X3DNode
   {
      throw X3DError .NOT_SUPPORTED ("getImportedNode")
   }

   public final func addImportedNode (inlineNode : Inline, exportedName : String, importedName : String = "") throws
   {
   }
   
   public final func updateImportedNode (inlineNode : Inline, exportedName : String, importedName : String = "") throws
   {
   }
   
   public final func removeImportedNode (importedName : String)
   {
   }
   
   // Proto handling
   
   public private(set) final var protos = [X3DProtoDeclaration] ()
   
   public final func createProtoDeclaration (name : String, interfaceDeclarations : [X3DInterfaceDeclaration], setup : Bool = true) -> X3DProtoDeclaration
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
   }
   
   public final func updateProtoDeclaration (name : String, proto : X3DProtoDeclaration) throws
   {
      guard !name .isEmpty else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add proto declaration: proto name is empty."))
      }

      guard !hasProtoDeclaration (name: name) else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add proto declaration: proto '%@' is already in use.", name))
      }

      if let existing = try? getProtoDeclaration (name: proto .getName ())
      {
         if existing === proto
         {
            proto .setName (name)
         }
         else
         {
            try addProtoDeclaration (name: name, proto: proto)
         }
      }
      else
      {
         try addProtoDeclaration (name: name, proto: proto)
      }
   }
   
   public final func removeProtoDeclaration (name : String)
   {
      protos .removeAll (where: { $0 .getName () == name })
   }
   
   public final func getProtoDeclaration (name : String) throws -> X3DProtoDeclaration
   {
      guard let proto = protos .first (where: { $0 .getName () == name }) else
      {
         throw X3DError .INVALID_NAME (t("Proto declaration '%@' not found.", name))
      }
      
      return proto
   }
   
   public final func hasProtoDeclaration (name : String) -> Bool
   {
      return protos .contains (where: { $0 .getName () == name })
   }
   
   // Extern proto handling
   
   public private(set) final var externprotos = [X3DExternProtoDeclaration] ()
   
   public final func createExternProtoDeclaration (name : String, interfaceDeclarations : [X3DInterfaceDeclaration], url : [String], setup : Bool = true) -> X3DExternProtoDeclaration
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
   }

   public final func updateExternProtoDeclaration (name : String, externproto : X3DExternProtoDeclaration) throws
   {
      guard !name .isEmpty else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add extern proto declaration: extern proto name is empty."))
      }

      guard !hasExternProtoDeclaration (name: name) else
      {
         throw X3DError .INVALID_NAME (t("Couldn't add extern proto declaration: extern proto '%@' is already in use.", name))
      }

      if let existing = try? getExternProtoDeclaration (name: externproto .getName ())
      {
         if existing === externproto
         {
            externproto .setName (name)
         }
         else
         {
            try addExternProtoDeclaration (name: name, externproto: externproto)
         }
      }
      else
      {
         try addExternProtoDeclaration (name: name, externproto: externproto)
      }
   }

   public final func removeExternProtoDeclaration (name : String)
   {
      externprotos .removeAll (where: { $0 .getName () == name })
   }

   public final func getExternProtoDeclaration (name : String) throws -> X3DExternProtoDeclaration
   {
      guard let externproto = externprotos .first (where: { $0 .getName () == name }) else
      {
         throw X3DError .INVALID_NAME (t("Extern proto declaration '%@' not found.", name))
      }
      
      return externproto
   }
   
   public final func hasExternProtoDeclaration (name : String) -> Bool
   {
      return externprotos .contains (where: { $0 .getName () == name })
   }

   // Route handling
   
   public private(set) final var routes = X3DRouteArray ()
   
   @discardableResult
   public final func addRoute (sourceNode : X3DNode,
                               sourceField : String,
                               destinationNode : X3DNode,
                               destinationField : String) throws -> X3DRoute
   {
      let sourceField      = try sourceNode      .getField (name: sourceField)
      let destinationField = try destinationNode .getField (name: destinationField)
      
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
      
      let route = X3DRoute (sourceNode, sourceField, destinationNode, destinationField)
      
      routes .append (route)
      
      return route
   }
   
   public final func deleteRoute (sourceNode : X3DNode,
                                  sourceField : String,
                                  destinationNode : X3DNode,
                                  destinationField : String)
   {
      guard let sourceField      = try? sourceNode      .getField (name: sourceField)      else { return }
      guard let destinationField = try? destinationNode .getField (name: destinationField) else { return }
      
      let index = routes .firstIndex (where:
      {
         route in route .sourceField === sourceField && route .destinationField === destinationField
      })
      
      guard index == nil else { return }
      
      routes .remove (at: index!)
  }

   public final func deleteRoute (route : X3DRoute)
   {
      guard let index = routes .firstIndex (of: route) else { return }
      
      routes .remove (at: index)
   }
}
