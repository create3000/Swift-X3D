//
//  X3DClassicParser.swift
//  X3D
//
//  Created by Holger Seelig on 16.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

internal final class VRMLParser :
   X3DParser,
   X3DParserInterface
{
   // Grammar

   private class Grammar
   {
      // Header
      
      static let header = try! NSRegularExpression (pattern: "^(VRML|X3D) V(.*?) (utf8)(?:[ \\t]+(.*?))?[ \\t]*$")
      
      // Whitespaces
      
      static let nothing     = CharacterSet ()
      static let lineBreak   = CharacterSet (charactersIn: "\r\n")
      static let whiteSpaces = CharacterSet (charactersIn: " \t\r\n,")
      static let comment     = "#"
      
      // Keywords
      
      static let AS          = "AS"
      static let COMPONENT   = "COMPONENT"
      static let DEF         = "DEF"
      static let EXPORT      = "EXPORT"
      static let EXTERNPROTO = "EXTERNPROTO"
      static let FALSE       = "FALSE"
      static let IMPORT      = "IMPORT"
      static let IS          = "IS"
      static let META        = "META"
      static let NULL        = "NULL"
      static let TRUE        = "TRUE"
      static let PROFILE     = "PROFILE"
      static let PROTO       = "PROTO"
      static let ROUTE       = "ROUTE"
      static let TO          = "TO"
      static let UNIT        = "UNIT"
      static let USE         = "USE"

      
      // Terminal symbols
      
      static let openBrace    = "{"
      static let closeBrace   = "}"
      static let openBracket  = "["
      static let closeBracket = "]"
      static let period       = "."
      static let colon        = ":"
      static let doubleQuotes = "\""
      static let substring    = CharacterSet (charactersIn: "\\\"")
      static let endstring    = Character ("\"")
      static let backSlash    = Character ("\\")

      // Id

      static let idFirstChar = CharacterSet (charactersIn: "\u{30}\u{31}\u{32}\u{33}\u{34}\u{35}\u{36}\u{37}\u{38}\u{39}\u{00}\u{01}\u{02}\u{03}\u{04}\u{05}\u{06}\u{07}\u{08}\u{09}\u{0a}\u{0b}\u{0c}\u{0d}\u{0e}\u{0f}\u{10}\u{11}\u{12}\u{13}\u{14}\u{15}\u{16}\u{17}\u{18}\u{19}\u{1a}\u{1b}\u{1c}\u{1d}\u{1e}\u{1f}\u{20}\u{22}\u{23}\u{27}\u{2b}\u{2c}\u{2d}\u{2e}\u{5b}\u{5c}\u{5d}\u{7b}\u{7d}\u{7f}") .inverted
      static let idLastChars = CharacterSet (charactersIn: "\u{00}\u{01}\u{02}\u{03}\u{04}\u{05}\u{06}\u{07}\u{08}\u{09}\u{0a}\u{0b}\u{0c}\u{0d}\u{0e}\u{0f}\u{10}\u{11}\u{12}\u{13}\u{14}\u{15}\u{16}\u{17}\u{18}\u{19}\u{1a}\u{1b}\u{1c}\u{1d}\u{1e}\u{1f}\u{20}\u{22}\u{23}\u{27}\u{2c}\u{2e}\u{5b}\u{5c}\u{5d}\u{7b}\u{7d}\u{7f}") .inverted
      static let componentNameId = CharacterSet (charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-")
      
      // Access types
      
      static let initializeOnly = "initializeOnly"
      static let inputOnly      = "inputOnly"
      static let outputOnly     = "outputOnly"
      static let inputOutput    = "inputOutput"
      static let field          = "field"
      static let eventIn        = "eventIn"
      static let eventOut       = "eventOut"
      static let exposedField   = "exposedField"
      
      // Field type

      static let fieldType = try! NSRegularExpression (pattern: "^(MFBool|MFColor|MFColorRGBA|MFDouble|MFFloat|MFImage|MFInt32|MFMatrix3d|MFMatrix3f|MFMatrix4d|MFMatrix4f|MFNode|MFRotation|MFString|MFTime|MFVec2d|MFVec2f|MFVec3d|MFVec3f|MFVec4d|MFVec4f|SFBool|SFColor|SFColorRGBA|SFDouble|SFFloat|SFImage|SFInt32|SFMatrix3d|SFMatrix3f|SFMatrix4d|SFMatrix4f|SFNode|SFRotation|SFString|SFTime|SFVec2d|SFVec2f|SFVec3d|SFVec3f|SFVec4d|SFVec4f)$")
      
      // Numbers
      
      static let hexPrefix        = "0x"
      static let nan              = "nan"
      static let positiveNan      = "+nan"
      static let negativeNan      = "-nan"
      static let infinity         = "inf"
      static let positiveInfinity = "+inf"
      static let negativeInfinity = "-inf"
      
      // XML
      
      static var `false` = "false"
      static var `true`  = "true"
   }

   // Properties
   
   private final var scene   : X3DScene
   private final var scanner : Scanner
   
   private final var lineNumber : Int
   {
      1 + scanner .string .prefix (upTo: scanner .currentIndex) .count (of: "\n")
   }
   
   // Construction
   
   internal init (scene : X3DScene, x3dSyntax : String)
   {
      // Set scene and create scanner.
      self .scene   = scene
      self .scanner = Scanner (string: x3dSyntax)
      
      // Configure scanner.
      self .scanner .caseSensitive         = true
      self .scanner .charactersToBeSkipped = Grammar .whiteSpaces

      // Init super.
      super .init ()
   }
   
   // Operations
   
   internal final var isValid : Bool
   {
      let currentIndex = scanner .currentIndex
      
      defer { scanner .currentIndex = currentIndex }
      
      comments ()
      
      if scanner .scanString (Grammar .PROFILE)     != nil { return true }
      if scanner .scanString (Grammar .COMPONENT)   != nil { return true }
      if scanner .scanString (Grammar .UNIT)        != nil { return true }
      if scanner .scanString (Grammar .META)        != nil { return true }
      if scanner .scanString (Grammar .PROTO)       != nil { return true }
      if scanner .scanString (Grammar .EXTERNPROTO) != nil { return true }
      if scanner .scanString (Grammar .IMPORT)      != nil { return true }
      if scanner .scanString (Grammar .EXPORT)      != nil { return true }
      if scanner .scanString (Grammar .ROUTE)       != nil { return true }
      if scanner .scanString (Grammar .DEF)         != nil { return true }
      if scanner .scanString (Grammar .USE)         != nil { return true }
      if scanner .scanString (Grammar .NULL)        != nil { return true }
      
      if let _ = nodeTypeId ()
      {
         comments ()
         
         if scanner .scanString (Grammar .openBrace) != nil
         {
            return true
         }
      }
      
      return false
   }

   internal final func parseIntoScene () throws
   {
      do
      {
         try x3dScene ()
      }
      catch let error as X3DError
      {
         throw X3DError .INVALID_X3D (t("Error in line %d. %@", lineNumber, error .description))
      }
   }

   // Parse
   
   private final func x3dScene () throws
   {
      executionContexts .append (scene)
      
      defer { executionContexts .removeLast () }

      headerStatement ()

      try profileStatement ()
      try componentStatements ()
      try unitStatements ()
      try metaStatements ()
      try statements ()

      guard scanner .isAtEnd else
      {
         throw X3DError .INVALID_X3D ("Unkown Statement.")
      }
   }
   
   private final func comments ()
   {
      while comment () { }
   }
   
   private final func comment () -> Bool
   {
      guard scanner .scanString (Grammar .comment) != nil else { return false }

      _ = scanner .scanUpToCharacters (from: Grammar .lineBreak)
      
      return true
   }

   private final func headerStatement ()
   {
      guard scanner .scanString (Grammar .comment) != nil                                 else { return }
      guard let headerCharacters = scanner .scanUpToCharacters (from: Grammar .lineBreak) else { return }
      guard let matches          = Grammar .header .matches (in: headerCharacters)        else { return }

      scene .encoding             = "VRML"
      scene .specificationVersion = matches [2]
      scene .characterEncoding    = matches [3]
      scene .comment              = matches [4]
   }
   
   private final func profileStatement () throws
   {
      comments ()
      
      guard scanner .scanString (Grammar .PROFILE) != nil else { return }

      guard let profileNameId = profileNameId () else
      {
         throw X3DError .INVALID_X3D (t("Expected a profile name."))
      }

      scene .profile = try scene .browser! .getProfile (name: profileNameId)
   }
   
   private final func componentStatements () throws
   {
      var components = X3DComponentInfoArray ()
      
      while let component = try componentStatement ()
      {
         components .append (component)
      }
      
      scene .components = components
   }
   
   private final func componentStatement () throws -> X3DComponentInfo?
   {
      comments ()
      
      guard scanner .scanString (Grammar .COMPONENT) != nil else { return nil }

      guard let componentNameId = componentNameId () else
      {
         throw X3DError .INVALID_X3D (t("Expected a component name."))
      }
      
      comments ()
      
      guard scanner .scanString (Grammar .colon) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected a ':' after component name."))
      }

      guard let componentSupportLevel = componentSupportLevel () else
      {
         throw X3DError .INVALID_X3D (t("Expected a component support level."))
      }

      return try scene .browser! .getComponent (name: componentNameId, level: componentSupportLevel)
   }
   
   private final func componentSupportLevel () -> Int32?
   {
      return int32 ()
   }

   private final func unitStatements () throws
   {
      while try unitStatement () { }
   }
   
   private final func unitStatement () throws -> Bool
   {
      comments ()
      
      guard scanner .scanString (Grammar .UNIT) != nil else { return false }

      guard let categoryNameId = categoryNameId () else
      {
         throw X3DError .INVALID_X3D (t("Expected unit category name identificator after UNIT statement."))
      }

      guard let category = X3DUnitCategory (categoryNameId) else
      {
         throw X3DError .INVALID_X3D (t("Unkown unit category '%@'.", categoryNameId))
      }

      guard let unitNameId = unitNameId () else
      {
         throw X3DError .INVALID_X3D (t("Expected unit name identificator."))
      }

      guard let unitConversionFactor = unitConversionFactor () else
      {
         throw X3DError .INVALID_X3D (t("Expected unit conversion factor."))
      }

      scene .updateUnit (category, name: unitNameId, conversionFactor: unitConversionFactor)
      
      return true
   }
   
   private final func unitConversionFactor () -> Double?
   {
      return double ()
   }
   
   private final func metaStatements () throws
   {
      while try metaStatement () { }
   }
   
   private final func metaStatement () throws -> Bool
   {
      comments ()

      guard scanner .scanString (Grammar .META) != nil else { return false }

      guard let metakey = metakey () else
      {
         throw X3DError .INVALID_X3D (t("Expected metadata key."))
      }

      guard let metavalue = metavalue () else
      {
         throw X3DError .INVALID_X3D (t("Expected metadata value."))
      }
      
      scene .metadata [metakey, default: [ ]] .append (metavalue)
      
      return true
   }
   
   private final func metakey () -> String?
   {
      return string ()
   }
   
   private final func metavalue () -> String?
   {
      return string ()
   }

   private final func importStatement () throws -> Bool
   {
      comments ()

      guard scanner .scanString (Grammar.IMPORT) != nil else { return false }

      guard let inlineNodeNameId = inlineNodeNameId () else
      {
         throw X3DError .INVALID_X3D (t("No name given after IMPORT statement."))
      }
   
      guard let inlineNode = try executionContext .getNamedNode (name: inlineNodeNameId) as? Inline else
      {
         throw X3DError .INVALID_X3D (t("Node named '%@' is not an Inline node.", inlineNodeNameId))
      }

      comments ()

      guard scanner .scanString (Grammar .period) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected a '.' after exported node name."))
      }
      
      guard let exportedNodeNameId = exportedNodeNameId () else
      {
         throw X3DError .INVALID_X3D (t("Expected exported node name."))
      }

      comments ()
      
      var importedNodeNameId : String? = ""

      if scanner .scanString (Grammar .AS) != nil
      {
         importedNodeNameId = self .nodeNameId ()
         
         guard importedNodeNameId != nil else
         {
            throw X3DError .INVALID_X3D (t("No name given after AS."))
         }
      }

      try executionContext .updateImportedNode (inlineNode: inlineNode, exportedName: exportedNodeNameId, importedName: importedNodeNameId!)

      return true
   }
   
   private final func exportStatement () throws -> Bool
   {
      comments ()

      guard scanner .scanString (Grammar .EXPORT) != nil else { return false }
   
      guard let localNodeNameId = nodeNameId () else
      {
         throw X3DError .INVALID_X3D (t("No name given after EXPORT."))
      }
 
      comments ()

      let node = try scene .getLocalNode (localName: localNodeNameId)
      var exportedNodeNameId : String? = ""

      if scanner .scanString (Grammar .AS) != nil
      {
         exportedNodeNameId = self .exportedNodeNameId ()
         
         guard exportedNodeNameId != nil else
         {
            throw X3DError .INVALID_X3D (t("No name given after AS."))
         }
      }
      else
      {
         exportedNodeNameId = localNodeNameId
      }

      try scene .updateExportedNode (exportedName: exportedNodeNameId!, node: node)

      return true
   }

   private final func statements () throws
   {
      while try statement () { }
   }

   private final func statement () throws -> Bool
   {
      if try protoStatement ()
      {
         return true
      }

      if try routeStatement ()
      {
         return true
      }

      if try importStatement ()
      {
         return true
      }

      if try exportStatement ()
      {
         return true
      }
      
      let (success, node) = try nodeStatement ()

      if success
      {
         executionContext .rootNodes .append (node)
         return true
      }
      
      return false
   }
   
   private final func nodeStatement () throws -> (Bool, X3DNode?)
   {
      comments ()
      
      if scanner .scanString (Grammar .DEF) != nil
      {
         guard let nodeNameId = nodeNameId () else
         {
            throw X3DError .INVALID_X3D (t("No name given after DEF."))
         }

         guard let node = try node (nodeNameId: nodeNameId) else
         {
            throw X3DError .INVALID_X3D (t("Expected node type name after DEF."))
         }
         
         return (true, node)
      }
      
      if scanner .scanString (Grammar .USE) != nil
      {
         guard let nodeNameId = nodeNameId () else
         {
            throw X3DError .INVALID_X3D (t("No name given after USE."))
         }
         
         let node = try executionContext .getNamedNode (name: nodeNameId)
         
         return (true, node)
      }

      if scanner .scanString (Grammar .NULL) != nil
      {
         return (true, nil)
      }

      if let node = try node ()
      {
         return (true, node)
      }
      
      return (false, nil)
   }
   
   private final func rootNodeStatement () throws -> (Bool, X3DNode?)
   {
      comments ()

      if scanner .scanString (Grammar .DEF) != nil
      {
         guard let nodeNameId = nodeNameId () else
         {
            throw X3DError .INVALID_X3D (t("No name given after DEF."))
         }

         guard let node = try node (nodeNameId: nodeNameId) else
         {
            throw X3DError .INVALID_X3D (t("Expected node type name after DEF."))
         }
         
         return (true, node)
      }

      if let node = try node ()
      {
         return (true, node)
      }
      
      return (false, nil)
   }

   private final func protoStatement () throws -> Bool
   {
      if try proto ()
      {
         return true
      }
      
      if try externproto ()
      {
         return true
      }
      
      return false
   }
   
   private final func protoStatements () throws
   {
      while try protoStatement () { }
   }
   
   private final func proto () throws -> Bool
   {
      comments ()

      guard scanner .scanString(Grammar .PROTO) != nil else
      {
         return false
      }

      guard let nodeTypeId = nodeTypeId () else
      {
         throw X3DError .INVALID_X3D (t("Invalid PROTO definition name."))
      }
      
      comments ()

      guard scanner .scanString (Grammar .openBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected a '[' at the beginning of PROTO interface declaration."))
      }

      let interfaceDeclarations = try self .interfaceDeclarations ()

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected a ']' at the end of PROTO interface declaration."))
      }

      comments ()

      guard scanner .scanString (Grammar .openBrace) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected a '{' at the beginning of PROTO body."))
      }

      let proto = executionContext .createProtoDeclaration (name: nodeTypeId, interfaceDeclarations: interfaceDeclarations, setup: false)

      do
      {
         protos            .append (proto)
         executionContexts .append (proto .body!)
         
         defer
         {
            protos            .removeLast ()
            executionContexts .removeLast ()
         }

         try protoBody ()
      }
      
      comments ()

      guard scanner .scanString (Grammar .closeBrace) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected a '}' at the end of PROTO body."))
      }

      try executionContext .updateProtoDeclaration (name: nodeTypeId, proto: proto)
      
      proto .setup ()

      return true
   }
   
   private final func protoBody () throws
   {
      try protoStatements ()
      
      let rootNode = try rootNodeStatement ()

      if rootNode .0
      {
         executionContext .rootNodes .append (rootNode .1)
      }

      try statements ()
   }

   private final func interfaceDeclarations () throws -> [X3DInterfaceDeclaration]
   {
      var interfaceDeclarations = [X3DInterfaceDeclaration] ()

      while let interfaceDeclaration = try interfaceDeclaration ()
      {
         interfaceDeclarations .append (interfaceDeclaration)
      }

      return interfaceDeclarations
   }
   
   private final func restrictedInterfaceDeclaration () throws -> X3DInterfaceDeclaration?
   {
      comments ()

      if scanner .scanString (Grammar .inputOnly) != nil || scanner .scanString (Grammar .eventIn) != nil
      {
         guard let fieldType = fieldType () else
         {
            throw X3DError .INVALID_X3D (t("Unknown event or field type."))
         }

         guard let fieldId = inputOnlyId () else
         {
            throw X3DError .INVALID_X3D ("Expected a name for field.")
         }

         let field = scene .browser! .supportedFields [fieldType]! .init ()
         
         return (.inputOnly, fieldId, field)
      }

      if scanner .scanString (Grammar .outputOnly) != nil || scanner .scanString (Grammar .eventOut) != nil
      {
         guard let fieldType = fieldType () else
         {
            throw X3DError .INVALID_X3D (t("Unknown event or field type."))
         }

         guard let fieldId = outputOnlyId () else
         {
            throw X3DError .INVALID_X3D ("Expected a name for field.")
         }

         let field = scene .browser! .supportedFields [fieldType]! .init ()
         
         return (.outputOnly, fieldId, field)
      }

      if scanner .scanString (Grammar .initializeOnly) != nil || scanner .scanString (Grammar .field) != nil
      {
         guard let fieldType = fieldType () else
         {
            throw X3DError .INVALID_X3D (t("Unknown event or field type."))
         }

         guard let fieldId = initializeOnlyId () else
         {
            throw X3DError .INVALID_X3D ("Expected a name for field.")
         }

         let field = scene .browser! .supportedFields [fieldType]! .init ()
         
         guard try fieldValue (for: field) else
         {
            throw X3DError .INVALID_X3D (t("Couldn't read value for field '%@'.", fieldId))
         }
         
         return (.initializeOnly, fieldId, field)
      }

      return nil
   }

   private final func interfaceDeclaration () throws -> X3DInterfaceDeclaration?
   {
      if let restrictedInterfaceDeclaration = try restrictedInterfaceDeclaration ()
      {
         return restrictedInterfaceDeclaration
      }

      if scanner .scanString (Grammar .inputOutput) != nil || scanner .scanString (Grammar .exposedField) != nil
      {
         guard let fieldType = fieldType () else
         {
            throw X3DError .INVALID_X3D (t("Unknown event or field type."))
         }

         guard let fieldId = inputOutputId () else
         {
            throw X3DError .INVALID_X3D ("Expected a name for field.")
         }

         let field = scene .browser! .supportedFields [fieldType]! .init ()
         
         guard try fieldValue (for: field) else
         {
            throw X3DError .INVALID_X3D (t("Couldn't read value for field '%@'.", fieldId))
         }
         
         return (.inputOutput, fieldId, field)
      }

      return nil
   }
   
   private final func externproto () throws -> Bool
   {
      comments ()

      guard scanner .scanString (Grammar .EXTERNPROTO) != nil else { return false }

      guard let nodeTypeId = nodeTypeId () else
      {
         throw X3DError .INVALID_X3D (t("Invalid EXTERNPROTO definition name."))
      }
   
      comments ()

      guard scanner .scanString (Grammar .openBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected a '[' at the beginning of EXTERNPROTO interface declaration."))
      }
      
      let externInterfaceDeclarations = try self .externInterfaceDeclarations ()
      
      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected a ']' at the end of EXTERNPROTO interface declaration."))
      }
 
      guard let URLList = try URLList () else
      {
         throw X3DError .INVALID_X3D (t("Expected a URL list after EXTERNPROTO interface declaration '%@'.", nodeTypeId))
      }
      
      let externproto = executionContext .createExternProtoDeclaration (name: nodeTypeId, interfaceDeclarations: externInterfaceDeclarations, url: URLList)

      try executionContext .updateExternProtoDeclaration (name: nodeTypeId, externproto: externproto)

      return true
   }

   private final func externInterfaceDeclarations () throws -> [X3DInterfaceDeclaration]
   {
      var externInterfaceDeclarations = [X3DInterfaceDeclaration] ()

      while let externInterfaceDeclaration = try externInterfaceDeclaration ()
      {
         externInterfaceDeclarations .append (externInterfaceDeclaration)
      }

      return externInterfaceDeclarations
   }
   
   private final func externInterfaceDeclaration () throws -> X3DInterfaceDeclaration?
   {
      comments ()

      if scanner .scanString (Grammar .inputOnly) != nil || scanner .scanString (Grammar .eventIn) != nil
      {
         guard let fieldType = fieldType () else
         {
            throw X3DError .INVALID_X3D (t("Unknown event or field type."))
         }

         guard let fieldId = inputOnlyId () else
         {
            throw X3DError .INVALID_X3D ("Expected a name for field.")
         }

         let field = scene .browser! .supportedFields [fieldType]! .init ()
         
         return (.inputOnly, fieldId, field)
      }

      if scanner .scanString (Grammar .outputOnly) != nil || scanner .scanString (Grammar .eventOut) != nil
      {
         guard let fieldType = fieldType () else
         {
            throw X3DError .INVALID_X3D (t("Unknown event or field type."))
         }

         guard let fieldId = outputOnlyId () else
         {
            throw X3DError .INVALID_X3D ("Expected a name for field.")
         }

         let field = scene .browser! .supportedFields [fieldType]! .init ()
         
         return (.outputOnly, fieldId, field)
      }

      if scanner .scanString (Grammar .initializeOnly) != nil || scanner .scanString (Grammar .field) != nil
      {
         guard let fieldType = fieldType () else
         {
            throw X3DError .INVALID_X3D (t("Unknown event or field type."))
         }

         guard let fieldId = initializeOnlyId () else
         {
            throw X3DError .INVALID_X3D ("Expected a name for field.")
         }

         let field = scene .browser! .supportedFields [fieldType]! .init ()
         
         return (.initializeOnly, fieldId, field)
      }

      if scanner .scanString (Grammar .inputOutput) != nil || scanner .scanString (Grammar .exposedField) != nil
      {
         guard let fieldType = fieldType () else
         {
            throw X3DError .INVALID_X3D (t("Unknown event or field type."))
         }

         guard let fieldId = inputOutputId () else
         {
            throw X3DError .INVALID_X3D ("Expected a name for field.")
         }

         let field = scene .browser! .supportedFields [fieldType]! .init ()
         
         return (.inputOutput, fieldId, field)
      }

      return nil
   }
   
   private final func URLList () throws -> [String]?
   {
      let value = MFString ()
      
      guard try mfstringValue (for: value) else { return nil }
      
      return Array <String> (value .wrappedValue)
   }

   private final func routeStatement () throws -> Bool
   {
      comments ()
      
      guard scanner .scanString (Grammar .ROUTE) != nil else
      {
         return false
      }
      
      guard let fromNodeId = nodeNameId () else
      {
         throw X3DError .INVALID_X3D (t("Bad ROUTE specification: Expected a node name."))
      }
      
      let fromNode = try executionContext .getLocalNode (localName: fromNodeId)
      
      comments ()
      
      guard scanner .scanString (Grammar .period) != nil else
      {
         throw X3DError .INVALID_X3D (t("Bad ROUTE specification: Expected a '.' after node name."))
      }

      guard let outputOnlyId = outputOnlyId () else
      {
         throw X3DError .INVALID_X3D (t("Bad ROUTE specification: Expected a field name."))
      }
      
      comments ()
      
      guard scanner .scanString (Grammar .TO) != nil else
      {
         throw X3DError .INVALID_X3D (t("Bad ROUTE specification: Expected a 'TO'."))
      }

      guard let toNodeId = nodeNameId () else
      {
         throw X3DError .INVALID_X3D (t("Bad ROUTE specification: Expected a node name."))
      }
      
      let toNode = try executionContext .getLocalNode (localName: toNodeId)
      
      comments ()
      
      guard scanner .scanString (Grammar .period) != nil else
      {
         throw X3DError .INVALID_X3D (t("Bad ROUTE specification: Expected a '.' after node name."))
      }
      
      guard let inputOnlyId = inputOnlyId () else
      {
         throw X3DError .INVALID_X3D (t("Bad ROUTE specification: Expected a field name."))
      }
      
      try executionContext .addRoute (sourceNode:       fromNode,
                                      sourceField:      outputOnlyId,
                                      destinationNode:  toNode,
                                      destinationField: inputOnlyId)

      return true
   }

   private final func node (nodeNameId : String? = nil) throws -> X3DNode?
   {
      guard let nodeTypeId = nodeTypeId () else { return nil }

      var node = try? executionContext .createNode (typeName: nodeTypeId, setup: false)
      
      if node == nil
      {
         node = try? executionContext .createProto (typeName: nodeTypeId, setup: false)
         
         if node == nil
         {
            throw X3DError .INVALID_X3D (t("Unknown node type or proto '%@'.", nodeTypeId))
         }
      }
      
      if nodeNameId != nil
      {
         if let namedNode = try? executionContext .getNamedNode (name: nodeNameId!)
         {
            try executionContext .updateNamedNode (name: executionContext .getUniqueName (for: nodeNameId!),
                                                   node: namedNode)
         }

         try! executionContext .addNamedNode (name: nodeNameId!, node: node!)
      }
      
      comments ()

      guard scanner .scanString (Grammar .openBrace) != nil else { return nil }
      
      if node! .canUserDefinedFields
      {
         try scriptBody (node!)
      }
      else
      {
         try nodeBody (node!)
      }
      
      comments ()

      guard scanner .scanString (Grammar .closeBrace) != nil else { return nil }

      if !isInsideProtoDefinition
      {
         node! .setup ()
      }
      
      return node
   }
   
   private final func scriptBody (_ node : X3DNode) throws
   {
      // TODO
      while try scriptBodyElement (node) { }
   }
   
   private final func scriptBodyElement (_ node : X3DNode) throws -> Bool
   {
      let currentIndex = scanner .currentIndex

      if let accessTypeId = id ()
      {
         if let accessType = X3DAccessType (accessTypeId) ?? X3DAccessType (vrml: accessTypeId)
         {
            if let fieldType = fieldType ()
            {
               if let fieldId = id ()
               {
                  comments ()

                  if scanner .scanString (Grammar .IS) != nil
                  {
                     guard isInsideProtoDefinition else
                     {
                        throw X3DError .INVALID_X3D (t("IS statement outside PROTO definition."))
                     }
                     
                     guard let isId = id () else
                     {
                        throw X3DError .INVALID_X3D (t("No name give after IS statement."))
                     }
                     
                     guard let reference = try? proto .getField (name: isId) else
                     {
                        throw X3DError .INVALID_X3D (t("No such event or field '%@' inside PROTO %@ interface declaration.", isId, proto .getName ()))
                     }

                     let supportedField = scene .browser! .supportedFields [fieldType]!

                     guard supportedField .type == reference .getType () else
                     {
                        throw X3DError .INVALID_X3D (t("Field '%@' and '%@' in PROTO '%@' have different types.", fieldId, reference .getName (), proto .getName ()))
                     }
                     
                     guard reference .isReference (for: accessType) else
                     {
                        throw X3DError .INVALID_X3D (t("Field '%@' and '%@' in PROTO '%@' are incompatible as an IS mapping.", fieldId, reference .getName (), proto .getName ()))
                     }
                     
                     var field = try? node .getField (name: fieldId)
                     
                     // If a field with exactly the same type is found, do not add a new field.
                     if !(field != nil && accessType == field! .getAccessType () && reference .getType () == field! .getType ())
                     {
                        field = addUserDefinedField (node, accessType, fieldId, supportedField)
                     }

                     field! .addReference (to: reference)

                     return true
                  }
               }
            }
         }

         // Reset stream position.
         scanner .currentIndex = currentIndex
      }

      if let interfaceDeclaration = try interfaceDeclaration ()
      {
         if let existingField = try? node .getField (name: interfaceDeclaration .name)
         {
            if interfaceDeclaration .accessType == existingField .getAccessType ()
            {
               if interfaceDeclaration .field .getType () == existingField .getType ()
               {
                  if interfaceDeclaration .field .isInitializable
                  {
                     existingField .set (value: interfaceDeclaration .field)
                  }
                  
                  return true
               }
            }
         }

         node .addUserDefinedField (interfaceDeclaration .accessType, interfaceDeclaration .name, interfaceDeclaration .field)

         return true
      }
      
      return try nodeBodyElement (node)
   }
   
   private final func addUserDefinedField (_ node : X3DBaseNode, _ accessType : X3DAccessType, _ fieldId : String, _ supportedField : X3DFieldInterface .Type) -> X3DField
   {
      let field = supportedField .init ()

      node .addUserDefinedField (accessType, fieldId, field)

      return field
   }

   private final func nodeBody (_ node : X3DNode) throws
   {
      while try nodeBodyElement (node) { }
   }

   private final func nodeBodyElement (_ node : X3DNode) throws -> Bool
   {
      if try protoStatement ()
      {
         return true
      }

      if try routeStatement ()
      {
         return true
      }

      guard let fieldId = id () else { return false }

      let field = try node .getField (name: fieldId)
      
      comments ()
      
      if scanner .scanString (Grammar .IS) != nil
      {
         guard isInsideProtoDefinition else
         {
            throw X3DError .INVALID_X3D (t("IS statement outside PROTO definition."))
         }
 
         guard let isId = id () else
         {
            throw X3DError .INVALID_X3D (t("No name give after IS statement."))
         }
         
         guard let reference = try? proto .getField (name: isId) else
         {
            throw X3DError .INVALID_X3D (t("No such event or field '%@' inside PROTO %@.", isId, proto .getName ()))
         }

         guard field .getType () == reference .getType () else
         {
            throw X3DError .INVALID_X3D (t("Field '%@' and '%@' in PROTO %@ have different types.", field .getName (), reference .getName (), proto .getName ()))
         }
         
         guard reference .isReference (for: field .getAccessType ()) else
         {
            throw X3DError .INVALID_X3D (t("Field '%@' and '%@' in PROTO %@ are incompatible as an IS mapping.", field .getName (), reference .getName (), proto .getName ()))
         }
   
         field .addReference (to: reference)
         
         return true
      }

      guard field .isInitializable else
      {
         throw X3DError .INVALID_X3D (t("Couldn't assign value to %@ field '%@', field is not initializable.", field .getAccessType () .description, fieldId))
      }

      guard try fieldValue (for: field) else
      {
         throw X3DError .INVALID_X3D (t("Couldn't read value for field '%@'.", fieldId))
      }

      return true
   }

   private final func id () -> String?
   {
      comments ()
      
      guard let idFirstChars = scanner .scanCharacters (from: Grammar .idFirstChar) else { return nil }
 
      scanner .charactersToBeSkipped = Grammar .nothing
      
      defer { scanner .charactersToBeSkipped = Grammar .whiteSpaces }

      let idLastChars = scanner .scanCharacters (from: Grammar .idLastChars)

      return idFirstChars + (idLastChars ?? "")
   }
   
   private final func profileNameId () -> String?
   {
      return id ()
   }
   
   private final func componentNameId () -> String?
   {
      comments ()

      guard let componentNameId = scanner .scanCharacters (from: Grammar .componentNameId) else { return nil }

      return componentNameId
   }
   
   private final func categoryNameId () -> String?
   {
      return id ()
   }

   private final func unitNameId () -> String?
   {
      return id ()
   }
   
   private final func nodeNameId () -> String?
   {
      return id ()
   }
   
   private final func nodeTypeId () -> String?
   {
      return id ()
   }
   
   private final func inlineNodeNameId () -> String?
   {
      return id ()
   }
   
   private final func exportedNodeNameId () -> String?
   {
      return id ()
   }
   
   private final func initializeOnlyId () -> String?
   {
      return id ()
   }
   
   private final func inputOnlyId () -> String?
   {
      return id ()
   }
   
   private final func inputOutputId () -> String?
   {
      return id ()
   }
   
   private final func outputOnlyId () -> String?
   {
      return id ()
   }
   
   private final func fieldType () -> String?
   {
      let currentIndex = scanner .currentIndex
      
      guard let fieldTypeId = id () else { return nil }
      
      guard let matches = Grammar .fieldType .matches (in: fieldTypeId) else
      {
         scanner .currentIndex = currentIndex
         return nil
      }

      return matches [1]
   }

   // Fields
   
   private final func fieldValue (for field : X3DField) throws -> Bool
   {
      switch field .getType ()
      {
         case .SFBool:      return sfboolValue      (for: field as! SFBool)
         case .SFColor:     return sfcolorValue     (for: field as! SFColor)
         case .SFColorRGBA: return sfcolorrgbaValue (for: field as! SFColorRGBA)
         case .SFDouble:    return sfdoubleValue    (for: field as! SFDouble)
         case .SFFloat:     return sffloatValue     (for: field as! SFFloat)
         case .SFImage:     return try sfimageValue (for: field as! SFImage)
         case .SFInt32:     return sfint32Value     (for: field as! SFInt32)
         case .SFMatrix3d:  return sfmatrix3dValue  (for: field as! SFMatrix3d)
         case .SFMatrix3f:  return sfmatrix3fValue  (for: field as! SFMatrix3f)
         case .SFMatrix4d:  return sfmatrix4dValue  (for: field as! SFMatrix4d)
         case .SFMatrix4f:  return sfmatrix4fValue  (for: field as! SFMatrix4f)
         case .SFNode:      return try sfnodeValue  (for: field as! SFNode <X3DNode>)
         case .SFRotation:  return sfrotationValue  (for: field as! SFRotation)
         case .SFString:    return sfstringValue    (for: field as! SFString)
         case .SFTime:      return sftimeValue      (for: field as! SFTime)
         case .SFVec2d:     return sfvec2dValue     (for: field as! SFVec2d)
         case .SFVec2f:     return sfvec2fValue     (for: field as! SFVec2f)
         case .SFVec3d:     return sfvec3dValue     (for: field as! SFVec3d)
         case .SFVec3f:     return sfvec3fValue     (for: field as! SFVec3f)
         case .SFVec4d:     return sfvec4dValue     (for: field as! SFVec4d)
         case .SFVec4f:     return sfvec4fValue     (for: field as! SFVec4f)

         case .MFBool:      return try mfboolValue      (for: field as! MFBool)
         case .MFColor:     return try mfcolorValue     (for: field as! MFColor)
         case .MFColorRGBA: return try mfcolorrgbaValue (for: field as! MFColorRGBA)
         case .MFDouble:    return try mfdoubleValue    (for: field as! MFDouble)
         case .MFFloat:     return try mffloatValue     (for: field as! MFFloat)
         case .MFMatrix3d:  return try mfmatrix3dValue  (for: field as! MFMatrix3d)
         case .MFMatrix3f:  return try mfmatrix3fValue  (for: field as! MFMatrix3f)
         case .MFMatrix4d:  return try mfmatrix4dValue  (for: field as! MFMatrix4d)
         case .MFMatrix4f:  return try mfmatrix4fValue  (for: field as! MFMatrix4f)
         case .MFImage:     return try mfimageValue     (for: field as! MFImage)
         case .MFInt32:     return try mfint32Value     (for: field as! MFInt32)
         case .MFNode:      return try mfnodeValue      (for: field as! MFNode <X3DNode>)
         case .MFRotation:  return try mfrotationValue  (for: field as! MFRotation)
         case .MFString:    return try mfstringValue    (for: field as! MFString)
         case .MFTime:      return try mftimeValue      (for: field as! MFTime)
         case .MFVec2d:     return try mfvec2dValue     (for: field as! MFVec2d)
         case .MFVec2f:     return try mfvec2fValue     (for: field as! MFVec2f)
         case .MFVec3d:     return try mfvec3dValue     (for: field as! MFVec3d)
         case .MFVec3f:     return try mfvec3fValue     (for: field as! MFVec3f)
         case .MFVec4d:     return try mfvec4dValue     (for: field as! MFVec4d)
         case .MFVec4f:     return try mfvec4fValue     (for: field as! MFVec4f)
      }
   }
   
   // Base values
   
   private final func bool () -> Bool?
   {
      comments ()
      
      if scanner .scanString (Grammar .FALSE) != nil
      {
         return false
      }
      
      if scanner .scanString (Grammar .TRUE) != nil
      {
         return true
      }
      
      return nil
   }
   
   private final func boolXML () -> Bool?
   {
      if scanner .scanString (Grammar .false) != nil
      {
         return false
      }
      
      if scanner .scanString (Grammar .true) != nil
      {
         return true
      }
      
      return nil
   }

   private final func double () -> Double?
   {
      comments ()
      
      if let value = scanner .scanDouble ()
      {
         return value
      }

      if scanner .scanString (Grammar .nan) != nil
      {
        return Double .nan
      }

      if scanner .scanString (Grammar .positiveNan) != nil
      {
        return +Double .nan
      }

      if scanner .scanString (Grammar .negativeNan) != nil
      {
        return -Double .nan
      }

      if scanner .scanString (Grammar .infinity) != nil
      {
        return Double .infinity
      }

      if scanner .scanString (Grammar .positiveInfinity) != nil
      {
        return +Double .infinity
      }

      if scanner .scanString (Grammar .negativeInfinity) != nil
      {
        return -Double .infinity
      }

      return nil
   }

   private final func float () -> Float?
   {
      comments ()
      
      if let value = scanner .scanFloat ()
      {
         return value
      }
      
      if scanner .scanString (Grammar .nan) != nil
      {
         return Float .nan
      }
      
      if scanner .scanString (Grammar .positiveNan) != nil
      {
         return +Float .nan
      }
      
      if scanner .scanString (Grammar .negativeNan) != nil
      {
         return -Float .nan
      }

      if scanner .scanString (Grammar .infinity) != nil
      {
        return Float .infinity
      }

      if scanner .scanString (Grammar .positiveInfinity) != nil
      {
        return +Float .infinity
      }

      if scanner .scanString (Grammar .negativeInfinity) != nil
      {
        return -Float .infinity
      }

      return nil
   }
   
   private final func int32 () -> Int32?
   {
      comments ()
      
      scanner .caseSensitive = false
      
      defer { scanner .caseSensitive = true }

      if scanner .scanString (Grammar .hexPrefix) != nil
      {
         return scanner .scanInt32 (representation: .hexadecimal)
      }
      
      return scanner .scanInt32 ()
   }
   
   private final func string () -> String?
   {
      var string = ""
      
      comments ()

      scanner .charactersToBeSkipped = Grammar .nothing

      defer { scanner .charactersToBeSkipped = Grammar .whiteSpaces }
      
      _ = scanner .scanCharacters (from: Grammar .whiteSpaces)

      guard scanner .scanString (Grammar .doubleQuotes) != nil else { return nil }
      
      while !scanner .isAtEnd
      {
         if let substring = scanner .scanUpToCharacters (from: Grammar .substring)
         {
            string += substring
         }
         
         if scanner .isAtEnd { break }

         // Double quotes
         
         if scanner .string [scanner .currentIndex] == Grammar .endstring { break }
         
         // Backslash
         
         scanner .currentIndex = scanner .string .index (after: scanner .currentIndex)
         
         if scanner .isAtEnd { break }

         string += String (scanner .string [scanner .currentIndex])
         
         scanner .currentIndex = scanner .string .index (after: scanner .currentIndex)
      }

      guard scanner .scanString (Grammar .doubleQuotes) != nil else { return nil }

      return string
   }

   // SFBool, MFBool
   
   internal final func sfboolValue (for field : SFBool) -> Bool
   {
      guard let value = bool () else { return false }
      
      field .wrappedValue = value
      return true
   }

   private final func mfboolValue (for field : MFBool) throws -> Bool
   {
      if let element = bool ()
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfboolValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfboolValues (for field : MFBool)
   {
      var value = ContiguousArray <Bool> ()

      while let element = bool ()
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }
   
   // XML SFBool, MFBool
   
   internal final func sfboolValueXML (for field : SFBool) -> Bool
   {
      guard let value = boolXML () else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   internal final func sfboolValuesXML (for field : MFBool)
   {
      var value = ContiguousArray <Bool> ()

      while let element = boolXML ()
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }


   // SFColor, MFColor
   
   internal final func sfcolorValue (for field : SFColor) -> Bool
   {
      guard let value = sfcolorValue () else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func sfcolorValue () -> Color3f?
   {
      guard let r = float () else { return nil }
      guard let g = float () else { return nil }
      guard let b = float () else { return nil }

      return Color3f (r, g, b)
   }
   
   private final func mfcolorValue (for field : MFColor) throws -> Bool
   {
      if let element = sfcolorValue ()
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfcolorValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfcolorValues (for field : MFColor)
   {
      var value = ContiguousArray <Color3f> ()

      while let element = sfcolorValue ()
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }
 
   // SFColorRGBA, MFColorRGBA
   
   internal final func sfcolorrgbaValue (for field : SFColorRGBA) -> Bool
   {
      guard let value = sfcolorrgbaValue () else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func sfcolorrgbaValue () -> Color4f?
   {
      guard let r = float () else { return nil }
      guard let g = float () else { return nil }
      guard let b = float () else { return nil }
      guard let a = float () else { return nil }

      return Color4f (r, g, b, a)
   }
   
   private final func mfcolorrgbaValue (for field : MFColorRGBA) throws -> Bool
   {
      if let element = sfcolorrgbaValue ()
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfcolorrgbaValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfcolorrgbaValues (for field : MFColorRGBA)
   {
      var value = ContiguousArray <Color4f> ()

      while let element = sfcolorrgbaValue ()
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFDouble, MFDouble
   
   internal final func sfdoubleValue (for field : SFDouble) -> Bool
   {
      guard let value = sfdoubleValue (with: field .unit) else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func sfdoubleValue (with unit : X3DUnitCategory) -> Double?
   {
      guard let value = double () else { return nil }
      
      return fromUnit (unit, value: value)
   }
   
   private final func mfdoubleValue (for field : MFDouble) throws -> Bool
   {
      if let element = sfdoubleValue (with: field .unit)
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfdoubleValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfdoubleValues (for field : MFDouble)
   {
      let unit  = field .unit
      var value = ContiguousArray <Double> ()

      while let element = sfdoubleValue (with: unit)
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFFloat, MFFloat
   
   internal final func sffloatValue (for field : SFFloat) -> Bool
   {
      guard let value = sffloatValue (with: field .unit) else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func sffloatValue (with unit : X3DUnitCategory) -> Float?
   {
      guard let value = float () else { return nil }
      
      return fromUnit (unit, value: value)
   }
   
   private final func mffloatValue (for field : MFFloat) throws -> Bool
   {
      if let element = sffloatValue (with: field .unit)
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sffloatValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sffloatValues (for field : MFFloat)
   {
      let unit  = field .unit
      var value = ContiguousArray <Float> ()

      while let element = sffloatValue (with: unit)
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFImage, MFImage

   internal final func sfimageValue (for field : SFImage) throws -> Bool
   {
      guard let width  = int32 () else { return false }
      guard let height = int32 () else { return false }
      guard let comp   = int32 () else { return false }

      field .wrappedValue .width  = width
      field .wrappedValue .height = height
      field .wrappedValue .comp   = comp
      
      let array = field .wrappedValue .array

      for i in 0 ..< width * height
      {
         guard let pixel = int32 () else
         {
            throw X3DError .INVALID_URL (t("Expected more pixel values."))
         }

         array [i] = pixel
      }
   
      return true
   }
   
   private final func mfimageValue (for field : MFImage) throws -> Bool
   {
      let element = SFImage ()
      
      if try sfimageValue (for: element)
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element .wrappedValue)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }

      try sfimageValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfimageValues (for field : MFImage) throws
   {
      field .wrappedValue .removeAll ()
      
      var element = SFImage ()

      while try sfimageValue (for: element)
      {
         field .wrappedValue .append (element .wrappedValue)
         
         element = SFImage ()
      }
   }
   
   // SFInt32, MFInt32
   
   internal final func sfint32Value (for field : SFInt32) -> Bool
   {
      guard let value = int32 () else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func mfint32Value (for field : MFInt32) throws -> Bool
   {
      if let element = int32 ()
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfint32Values (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfint32Values (for field : MFInt32)
   {
      var value = ContiguousArray <Int32> ()

      while let element = int32 ()
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }
   
   // SFMatrix3d, MFMatrix3d
   
   internal final func sfmatrix3dValue (for field : SFMatrix3d) -> Bool
   {
      guard let value = sfmatrix3dValue () else { return false }
      
      field .wrappedValue = value
      return true
   }

   private final func sfmatrix3dValue () -> Matrix3d?
   {
      guard let e0 = double () else { return nil }
      guard let e1 = double () else { return nil }
      guard let e2 = double () else { return nil }
      guard let e3 = double () else { return nil }
      guard let e4 = double () else { return nil }
      guard let e5 = double () else { return nil }
      guard let e6 = double () else { return nil }
      guard let e7 = double () else { return nil }
      guard let e8 = double () else { return nil }

      return Matrix3d (columns: (
         Vector3d (e0, e1, e2),
         Vector3d (e3, e4, e5),
         Vector3d (e6, e7, e8)
      ))
   }
   
   private final func mfmatrix3dValue (for field : MFMatrix3d) throws -> Bool
   {
      if let element = sfmatrix3dValue ()
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfmatrix3dValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfmatrix3dValues (for field : MFMatrix3d)
   {
      var value = ContiguousArray <Matrix3d> ()

      while let element = sfmatrix3dValue ()
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFMatrix3f, MFMatrix3f
   
   internal final func sfmatrix3fValue (for field : SFMatrix3f) -> Bool
   {
      guard let value = sfmatrix3fValue () else { return false }
      
      field .wrappedValue = value
      return true
   }

   private final func sfmatrix3fValue () -> Matrix3f?
   {
      guard let e0 = float () else { return nil }
      guard let e1 = float () else { return nil }
      guard let e2 = float () else { return nil }
      guard let e3 = float () else { return nil }
      guard let e4 = float () else { return nil }
      guard let e5 = float () else { return nil }
      guard let e6 = float () else { return nil }
      guard let e7 = float () else { return nil }
      guard let e8 = float () else { return nil }

      return Matrix3f (columns: (
         Vector3f (e0, e1, e2),
         Vector3f (e3, e4, e5),
         Vector3f (e6, e7, e8)
      ))
   }
   
   private final func mfmatrix3fValue (for field : MFMatrix3f) throws -> Bool
   {
      if let element = sfmatrix3fValue ()
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfmatrix3fValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfmatrix3fValues (for field : MFMatrix3f)
   {
      var value = ContiguousArray <Matrix3f> ()

      while let element = sfmatrix3fValue ()
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFMatrix4d, MFMatrix4d
   
   internal final func sfmatrix4dValue (for field : SFMatrix4d) -> Bool
   {
      guard let value = sfmatrix4dValue () else { return false }
      
      field .wrappedValue = value
      return true
   }

   private final func sfmatrix4dValue () -> Matrix4d?
   {
      guard let e00 = double () else { return nil }
      guard let e01 = double () else { return nil }
      guard let e02 = double () else { return nil }
      guard let e03 = double () else { return nil }
      guard let e04 = double () else { return nil }
      guard let e05 = double () else { return nil }
      guard let e06 = double () else { return nil }
      guard let e07 = double () else { return nil }
      guard let e08 = double () else { return nil }
      guard let e09 = double () else { return nil }
      guard let e10 = double () else { return nil }
      guard let e11 = double () else { return nil }
      guard let e12 = double () else { return nil }
      guard let e13 = double () else { return nil }
      guard let e14 = double () else { return nil }
      guard let e15 = double () else { return nil }

      return Matrix4d (columns: (
         Vector4d (e00, e01, e02, e03),
         Vector4d (e04, e05, e06, e07),
         Vector4d (e08, e09, e10, e11),
         Vector4d (e12, e13, e14, e15)
      ))
   }
   
   private final func mfmatrix4dValue (for field : MFMatrix4d) throws -> Bool
   {
      if let element = sfmatrix4dValue ()
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfmatrix4dValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfmatrix4dValues (for field : MFMatrix4d)
   {
      var value = ContiguousArray <Matrix4d> ()

      while let element = sfmatrix4dValue ()
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFMatrix4f, MFMatrix4f
   
   internal final func sfmatrix4fValue (for field : SFMatrix4f) -> Bool
   {
      guard let value = sfmatrix4fValue () else { return false }
      
      field .wrappedValue = value
      return true
   }

   private final func sfmatrix4fValue () -> Matrix4f?
   {
      guard let e00 = float () else { return nil }
      guard let e01 = float () else { return nil }
      guard let e02 = float () else { return nil }
      guard let e03 = float () else { return nil }
      guard let e04 = float () else { return nil }
      guard let e05 = float () else { return nil }
      guard let e06 = float () else { return nil }
      guard let e07 = float () else { return nil }
      guard let e08 = float () else { return nil }
      guard let e09 = float () else { return nil }
      guard let e10 = float () else { return nil }
      guard let e11 = float () else { return nil }
      guard let e12 = float () else { return nil }
      guard let e13 = float () else { return nil }
      guard let e14 = float () else { return nil }
      guard let e15 = float () else { return nil }

      return Matrix4f (columns: (
         Vector4f (e00, e01, e02, e03),
         Vector4f (e04, e05, e06, e07),
         Vector4f (e08, e09, e10, e11),
         Vector4f (e12, e13, e14, e15)
      ))
   }
   
   private final func mfmatrix4fValue (for field : MFMatrix4f) throws -> Bool
   {
      if let element = sfmatrix4fValue ()
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfmatrix4fValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfmatrix4fValues (for field : MFMatrix4f)
   {
      var value = ContiguousArray <Matrix4f> ()

      while let element = sfmatrix4fValue ()
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }
   
   // SFNode, MFNode
   
   private final func sfnodeValue (for field : SFNode <X3DNode>) throws -> Bool
   {
      let (success, node) = try nodeStatement ()
      
      guard success else { return false }
      
      field .wrappedValue = node
      return true
   }
   
   private final func mfnodeValue (for field : MFNode <X3DNode>) throws -> Bool
   {
      let (success, node) = try nodeStatement ()
      
      if success
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (node)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      try nodeStatements (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }

   private final func nodeStatements (for field : MFNode <X3DNode>) throws
   {
      var value = [X3DNode?] ()
      
      var (success, node) = try nodeStatement ()
      
      while success
      {
         value .append (node)

         (success, node) = try nodeStatement ()
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }
   
   // SFRotation, MFRotation
   
   internal final func sfrotationValue (for field : SFRotation) -> Bool
   {
      guard let value = sfrotationValue () else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func sfrotationValue () -> Rotation4f?
   {
      guard let x = float () else { return nil }
      guard let y = float () else { return nil }
      guard let z = float () else { return nil }
      guard let a = float () else { return nil }

      return Rotation4f (x, y, z, fromUnit (.angle, value: a))
   }
   
   private final func mfrotationValue (for field : MFRotation) throws -> Bool
   {
      if let element = sfrotationValue ()
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfrotationValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfrotationValues (for field : MFRotation)
   {
      var value = ContiguousArray <Rotation4f> ()

      while let element = sfrotationValue ()
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFString, MFString
   
   internal final func sfstringValue (for field : SFString) -> Bool
   {
      guard let value = string () else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func mfstringValue (for field : MFString) throws -> Bool
   {
      if let element = string ()
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfstringValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfstringValues (for field : MFString)
   {
      var value = ContiguousArray <String> ()

      while let element = string ()
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFTime, MFTime
   
   internal final func sftimeValue (for field : SFTime) -> Bool
   {
      guard let value = double () else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func mftimeValue (for field : MFTime) throws -> Bool
   {
      if let element = double ()
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sftimeValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sftimeValues (for field : MFTime)
   {
      var value = ContiguousArray <TimeInterval> ()

      while let element = double ()
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFVec2d, MFVec2d
   
   internal final func sfvec2dValue (for field : SFVec2d) -> Bool
   {
      guard let value = sfvec2dValue (with: field .unit) else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func sfvec2dValue (with unit : X3DUnitCategory) -> Vector2d?
   {
      guard let x = double () else { return nil }
      guard let y = double () else { return nil }

      return Vector2d (fromUnit (unit, value: x),
                       fromUnit (unit, value: y))
   }
   
   private final func mfvec2dValue (for field : MFVec2d) throws -> Bool
   {
      if let element = sfvec2dValue (with: field .unit)
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfvec2dValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfvec2dValues (for field : MFVec2d)
   {
      let unit  = field .unit
      var value = ContiguousArray <Vector2d> ()

      while let element = sfvec2dValue (with: unit)
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFVec2f, MFVec2f
   
   internal final func sfvec2fValue (for field : SFVec2f) -> Bool
   {
      guard let value = sfvec2fValue (with: field .unit) else { return false }

      field .wrappedValue = value
      return true
   }
   
   private final func sfvec2fValue (with unit : X3DUnitCategory) -> Vector2f?
   {
      guard let x = float () else { return nil }
      guard let y = float () else { return nil }

      return Vector2f (fromUnit (unit, value: x),
                       fromUnit (unit, value: y))
   }
   
   private final func mfvec2fValue (for field : MFVec2f) throws -> Bool
   {
      if let element = sfvec2fValue (with: field .unit)
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfvec2fValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfvec2fValues (for field : MFVec2f)
   {
      let unit  = field .unit
      var value = ContiguousArray <Vector2f> ()

      while let element = sfvec2fValue (with: unit)
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFVec3d, MFVec3d
   
   internal final func sfvec3dValue (for field : SFVec3d) -> Bool
   {
      guard let value = sfvec3dValue (with: field .unit) else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func sfvec3dValue (with unit : X3DUnitCategory) -> Vector3d?
   {
      guard let x = double () else { return nil }
      guard let y = double () else { return nil }
      guard let z = double () else { return nil }

      return Vector3d (fromUnit (unit, value: x),
                       fromUnit (unit, value: y),
                       fromUnit (unit, value: z))
   }
   
   private final func mfvec3dValue (for field : MFVec3d) throws -> Bool
   {
      if let element = sfvec3dValue (with: field .unit)
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfvec3dValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfvec3dValues (for field : MFVec3d)
   {
      let unit  = field .unit
      var value = ContiguousArray <Vector3d> ()

      while let element = sfvec3dValue (with: unit)
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFVec3f, MFVec3f
   
   internal final func sfvec3fValue (for field : SFVec3f) -> Bool
   {
      guard let value = sfvec3fValue (with: field .unit) else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func sfvec3fValue (with unit : X3DUnitCategory) -> Vector3f?
   {
      guard let x = float () else { return nil }
      guard let y = float () else { return nil }
      guard let z = float () else { return nil }

      return Vector3f (fromUnit (unit, value: x),
                       fromUnit (unit, value: y),
                       fromUnit (unit, value: z))
   }
   
   private final func mfvec3fValue (for field : MFVec3f) throws -> Bool
   {
      if let element = sfvec3fValue (with: field .unit)
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfvec3fValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfvec3fValues (for field : MFVec3f)
   {
      let unit  = field .unit
      var value = ContiguousArray <Vector3f> ()

      while let element = sfvec3fValue (with: unit)
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }
   
   // SFVec4d, MFVec4d
   
   internal final func sfvec4dValue (for field : SFVec4d) -> Bool
   {
      guard let value = sfvec4dValue (with: field .unit) else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func sfvec4dValue (with unit : X3DUnitCategory) -> Vector4d?
   {
      guard let x = double () else { return nil }
      guard let y = double () else { return nil }
      guard let z = double () else { return nil }
      guard let w = double () else { return nil }

      return Vector4d (fromUnit (unit, value: x),
                       fromUnit (unit, value: y),
                       fromUnit (unit, value: z),
                       fromUnit (unit, value: w))
   }
   
   private final func mfvec4dValue (for field : MFVec4d) throws -> Bool
   {
      if let element = sfvec4dValue (with: field .unit)
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfvec4dValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfvec4dValues (for field : MFVec4d)
   {
      let unit  = field .unit
      var value = ContiguousArray <Vector4d> ()

      while let element = sfvec4dValue (with: unit)
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }

   // SFVec4f, MFVec4f
   
   internal final func sfvec4fValue (for field : SFVec4f) -> Bool
   {
      guard let value = sfvec4fValue (with: field .unit) else { return false }
      
      field .wrappedValue = value
      return true
   }
   
   private final func sfvec4fValue (with unit : X3DUnitCategory) -> Vector4f?
   {
      guard let x = float () else { return nil }
      guard let y = float () else { return nil }
      guard let z = float () else { return nil }
      guard let w = float () else { return nil }

      return Vector4f (fromUnit (unit, value: x),
                       fromUnit (unit, value: y),
                       fromUnit (unit, value: z),
                       fromUnit (unit, value: w))
   }
   
   private final func mfvec4fValue (for field : MFVec4f) throws -> Bool
   {
      if let element = sfvec4fValue (with: field .unit)
      {
         field .wrappedValue .removeAll ()
         field .wrappedValue .append (element)
         return true
      }

      guard scanner .scanString (Grammar .openBracket) != nil else { return false }
      
      sfvec4fValues (for: field)

      comments ()

      guard scanner .scanString (Grammar .closeBracket) != nil else
      {
         throw X3DError .INVALID_X3D (t("Expected ']'."))
      }

      return true
   }
   
   internal final func sfvec4fValues (for field : MFVec4f)
   {
      let unit  = field .unit
      var value = ContiguousArray <Vector4f> ()

      while let element = sfvec4fValue (with: unit)
      {
         value .append (element)
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)
   }
}

fileprivate extension Collection
   where Element : Equatable
{
   func count (of needle : Element) -> Int
   {
      reduce (0) { $1 == needle ? $0 + 1 : $0 }
   }
}
