//
//  XMLParser.swift
//  X3D
//
//  Created by Holger Seelig on 18.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

internal final class XMLParser :
   X3DParser,
   X3DParserInterface
{
   // Properties
   
   private final var scene    : X3DScene
   private final var document : XMLDocument?
   private final var parents  : [X3DChildObject] = [ ]
   
   // Construction
   
   internal init (scene : X3DScene, x3dSyntax : String)
   {
      // Set scene and create xml parser.
      self .scene    = scene
      self .document = try? XMLDocument (xmlString: x3dSyntax)

      // Init super.
      super .init ()
      
      executionContexts .append (scene)
   }
   
   // Operations
   
   internal final var isValid : Bool
   {
      guard let document = document else { return false }
      
      return document .rootElement () != nil
   }

   internal final func parseIntoScene () throws
   {
      guard let document = document else
      {
         throw X3DError .INVALID_DOCUMENT ("Couldn't parse XML data.")
      }
      
      x3dElement (document .rootElement ())
   }
   
   // Parse
   
   private final var console : X3DConsole { scene .browser! .console }
   
   private final func x3dElement (_ element : XMLElement?)
   {
      guard let element = element else { return }
      
      guard element .name == "X3D" else { return }
      
      scene .setEncoding ("XML")
      
      if let profile = element .attribute (name: "profile")
      {
         do
         {
            scene .setProfile (try scene .browser! .getProfile (name: profile))
         }
         catch
         {
            console .warn (t("XML parser error: %@", error .localizedDescription))
         }
      }
      
      if let version = element .attribute (name: "version")
      {
         scene .setSpecificationVersion (version)
      }

      x3dElementChildren (element .children)
   }
   
   private final func x3dElementChildren (_ children : [XMLNode]?)
   {
      guard let children = children else { return }
      
      for child in children
      {
         x3dElementChild (child as? XMLElement)
      }
   }
   
   private final func x3dElementChild (_ element : XMLElement?)
   {
      switch element? .name
      {
         case "head":
            headElement (element)
         case "Scene":
            sceneElement (element)
         default:
            break
      }
   }
   
   private final func headElement (_ element : XMLElement?)
   {
      guard let element = element else { return }
      
      headElementChildren (element .children)
   }
   
   private final func headElementChildren (_ children : [XMLNode]?)
   {
      guard let children = children else { return }
      
      for child in children
      {
         headElementChild (child as? XMLElement)
      }
   }
   
   private final func headElementChild (_ element : XMLElement?)
   {
      switch element? .name
      {
         case "component":
            componentElement (element)
         case "unit":
            unitElement (element)
         case "meta":
            metaElement (element)
         default:
            break
      }
   }
   
   private final func componentElement (_ element : XMLElement?)
   {
      do
      {
         guard let element = element else { return }
      
         guard let componentNameId = element .attribute (name: "name") else
         {
            return console .warn (t("XML parser error: Bad component statement. Expected name attribute."))
         }

         guard let componentSupportLevel = Int32 (element .attribute (name: "level") ?? "") else
         {
            return console .warn (t("XML parser error: Bad component statement. Expected level attribute."))
         }

         let component = try scene .browser! .getComponent (name: componentNameId, level: componentSupportLevel)
         
         scene .addComponent (component)
      }
      catch
      {
         console .warn (error .localizedDescription)
      }
   }
   
   private final func unitElement (_ element : XMLElement?)
   {
      guard let element = element else { return }

      guard let categoryNameId = element .attribute (name: "category") else
      {
         return console .warn (t("XML parser error: bad unit statement. Expected category attribute."))
      }

      guard let category = X3DUnitCategory (categoryNameId) else
      {
         return console .warn (t("XML parser error: unkown unit category '%@'.", categoryNameId))
      }

      guard let name = element .attribute (name: "name") else
      {
         return console .warn (t("XML parser error: bad unit statement. Expected name attribute."))
      }

      guard let conversionFactor = Double (element .attribute (name: "conversionFactor") ?? "") else
      {
         return console .warn (t("XML parser error: bad unit statement. Expected conversionFactor attribute."))
      }

      scene .updateUnit (category, name: name, conversionFactor: conversionFactor)
   }

   private final func metaElement (_ element : XMLElement?)
   {
      guard let element = element else { return }
      
      guard let metakey = element .attribute (name: "name") else
      {
         return console .warn (t("XML parser error: bad meta statement. Expected name attribute."))
      }
      
      guard let metavalue = element .attribute (name: "content") else
      {
         return console .warn (t("XML parser error: bad meta statement. Expected content attribute."))
      }
      
      scene .addMetaData (key: metakey, value: metavalue)
   }
   
   //     .--..--..--..--..--..--.
   //   .' \  (`._   (_)     _   \
   //  .'    |  '._)         (_)  |
   //  \ _.')\      .----..---.   /
   //  |(_.'  |    /    .-\-.  \  |
   //  \     0|    |   ( O| O) | o|
   //  |  _  |  .--.____.'._.-.  |
   //  \ (_) | o         -` .-`  |
   //   |    \   |`-._ _ _ _ _\ /
   //   \    |   |  `. |_||_|   |
   //   | o  |    \_      \     |     -.   .-.
   //   |.-.  \     `--..-'   O |     `.`-' .'
   //  _.'  .' |     `-.-'      /-.__   ' .-'
   //  .' `-.` '.|='=.='=.='=.='=|._/_ `-'.'
   //  `-._  `.  |________/\_____|    `-.'
   //  .'   ).| '=' '='\/ '=' |
   //  `._.`  '---------------'
   //          //___\   //___\
   //            ||       ||
   //   LGB      ||_.-.   ||_.-.
   //           (_.--__) (_.--__)

   private final func sceneElement (_ element : XMLElement?)
   {
      guard let element = element else { return }
      
      childrenElements (element .children)
   }

   private final func childrenElements (_ children : [XMLNode]?)
   {
      guard let children = children else { return }
      
      for child in children
      {
         childElement (child)
      }
   }

   private final func childElement (_ node : XMLNode?)
   {
      guard let node = node else { return }
      
      switch node .kind
      {
         case XMLNode .Kind .text: do
         {
            cdataNode (node)
         }
         case XMLNode .Kind .element: do
         {
            let element = node as? XMLElement
            
            switch element? .name
            {
               case "ExternProtoDeclare":
                  externProtoDeclareElement (element)
               case "ProtoDeclare":
                  protoDeclareElement (element)
               case "IS":
                  isElement (element)
               case "ProtoInstance":
                  protoInstanceElement (element)
               case "fieldValue":
                  fieldValueElement (element)
               case "field":
                  fieldElement (element)
               case "ROUTE":
                  routeElement (element)
               case "IMPORT":
                  importElement (element)
               case "EXPORT":
                  exportElement (element)
               default:
                  nodeElement (element)
            }
         }
         default:
            break
      }
   }

   private final func cdataNode (_ element : XMLNode?)
   {
      guard let element = element else { return }

      guard let node = parents .last as? X3DNode else { return }

      guard let field = node .getSourceText () else { return }
      
      guard let value = element .stringValue else { return }
      
      field .wrappedValue .append (value)
   }
   
   private final func externProtoDeclareElement (_ element : XMLElement?)
   {
      do
      {
         guard let element = element else { return }
         
         guard let name = element .attribute (name: "name") else
         {
            return console .warn (t("XML parser error: bad ExternProtoDeclare statement, expected name attribute."))
         }
         
         guard let url = element .attribute (name: "url") else
         {
            return console .warn (t("XML parser error: bad ExternProtoDeclare statement, expected url attribute."))
         }
         
         // Parse url.
         
         let field = MFString ()
         
         fieldValue (field, url)

         // Create externproto and parse fields.
         
         let externproto = executionContext .createExternProtoDeclaration (name: name, interfaceDeclarations: [ ], url: Array <String> (field .wrappedValue), setup: false)

         parents .append (externproto)
         
         defer { parents .removeLast () }

         protoInterfaceElement (element) // Parse fields.
         
         try executionContext .updateExternProtoDeclaration (name: name, externproto: externproto)
         
         externproto .setup ()
      }
      catch
      {
         console .warn (t("XML parser error: %@", error .localizedDescription))
      }
   }

   private final func protoDeclareElement (_ element : XMLElement?)
   {
      do
      {
         guard let element = element else { return }
         
         guard let name = element .attribute (name: "name") else
         {
            return console .warn (t("XML parser error: bad ProtoDeclare statement, expected name attribute."))
         }
         
         let proto = executionContext .createProtoDeclaration (name: name, interfaceDeclarations: [ ], setup: false)

         if let children = element .children
         {
            for child in children
            {
               guard child .name == "ProtoInterface" else { continue }
            
               parents .append (proto)
               
               defer { parents .removeLast () }
               
               protoInterfaceElement (child as? XMLElement)
            }
         }

         if let children = element .children
         {
            for child in children
            {
               guard child .name == "ProtoBody" else { continue }
               
               protos            .append (proto)
               executionContexts .append (proto .body)
               parents           .append (proto)
               
               defer
               {
                  protos            .removeLast ()
                  executionContexts .removeLast ()
                  parents           .removeLast ()
               }

               protoBodyElement (child as? XMLElement)
            }
         }

         try executionContext .updateProtoDeclaration (name: name, proto: proto)
         
         proto .setup ()
      }
      catch
      {
         console .warn (t("XML parser error: %@", error .localizedDescription))
      }
   }

   private final func protoInterfaceElement (_ element : XMLElement?)
   {
      guard let element = element else { return }
      
      protoInterfaceElementChildren (element .children)
   }

   private final func protoInterfaceElementChildren (_ children : [XMLNode]?)
   {
      guard let children = children else { return }
      
      for child in children
      {
         protoInterfaceElementChild (child as? XMLElement)
      }
   }

   private final func protoInterfaceElementChild (_ element : XMLElement?)
   {
      guard let element = element else { return }
      
      if element .name == "field"
      {
         fieldElement (element)
      }
   }

   private final func protoBodyElement (_ element : XMLElement?)
   {
      guard let element = element else { return }
      
      childrenElements (element .children)
   }
   
   private final func isElement (_ element : XMLElement?)
   {
      guard let element = element else { return }
      
      guard isInsideProtoDefinition else
      {
         return console .warn (t("XML parser error: is element is only allowed inside proto declaration."))
      }
      
      isElementChildren (element .children)
   }

   private final func isElementChildren (_ children : [XMLNode]?)
   {
      guard let children = children else { return }
      
      for child in children
      {
         isElementChild (child as? XMLElement)
      }
   }
   
   private final func isElementChild (_ element : XMLElement?)
   {
      switch element? .name
      {
         case "connect":
            connectElement (element)
         default:
            break
      }
   }
   
   private final func connectElement (_ element : XMLElement?)
   {
      do
      {
         guard let element = element else { return }
         
         guard !parents .isEmpty else { return }

         guard let node = parents .last as? X3DNode else
         {
            return console .warn (t("XML parser error: parent node must be of type X3DNode at least."))
         }

         guard let nodeFieldName = element .attribute (name: "nodeField") else
         {
            return console .warn (t("XML parser error: bad connect statement, expected nodeField attribute."))
         }

         guard let protoFieldName = element .attribute (name: "protoField") else
         {
            return console .warn (t("XML parser error: bad connect statement, expected protoField attribute."))
         }

         let nodeField  = try node  .getField (name: nodeFieldName)
         let protoField = try proto .getField (name: protoFieldName)
         
         guard nodeField .getType () == protoField .getType () else
         {
            return console .warn (t("XML parser error: field '%@' and '%@' in PROTO %@ have different types.", nodeField .getName (), protoField .getName (), proto .getName ()))
         }
         
         guard protoField .isReference (for: nodeField .getAccessType ()) else
         {
            return console .warn (t("XML parser error: field '%@' and '%@' in PROTO %@ are incompatible as an IS mapping.", nodeField .getName (), protoField .getName (), proto .getName ()))
         }

         nodeField .addReference (to: protoField)
      }
      catch
      {
         console .warn (t("XML parser error: %@", error .localizedDescription))
      }
   }
   
   private final func protoInstanceElement (_ element : XMLElement?)
   {
      do
      {
         guard let element = element else { return }
      
         // USE property
      
         if useAttribute (element) { return }

         // Node object
         
         guard let name = element .attribute (name: "name") else
         {
            return console .warn (t("XML parser error: expected name attribute."))
         }
        
         let instance = try executionContext .createProto (typeName: name, setup: false)

         defAttribute (element, instance)

         addNode (element, instance)

         parents .append (instance)
         
         defer { parents .removeLast () }

         childrenElements (element .children)

         if !isInsideProtoDefinition
         {
            instance .setup ()
         }
      }
      catch
      {
         console .warn (t("XML parser error: %@", error .localizedDescription))
      }
   }

   private final func fieldValueElement (_ element : XMLElement?)
   {
      guard let element = element else { return }
      
      guard !parents .isEmpty else { return }
      
      guard let instance = parents .last as? X3DPrototypeInstance else
      {
         return console .warn ("XML parser error: parent node is not an X3DPrototypeInstance.")
      }
      
      guard let name = element .attribute (name: "name") else
      {
         return console .warn (t("XML parser error: expected name attribute."))
      }

      guard let field = try? instance .getField (name: name) else
      {
         return console .warn (t("XML parser error: No such field '%@' in node type %@.", name, instance .getTypeName ()))
      }

      if field .isInitializable
      {
         fieldValue (field, element .attribute (name: "value"))

         parents .append (field)
         
         defer { parents .removeLast () }

         childrenElements (element .children)
      }
   }

   private final func fieldElement (_ element : XMLElement?)
   {
      guard let element = element else { return }
      
      guard let node = parents .last as? X3DBaseNode else { return }

      guard node .canUserDefinedFields else
      {
         return console .warn (t("XML parser error: node type %@ does not support user-defined fields.", node .getTypeName ()))
      }

      let accessType = X3DAccessType (element .attribute (name: "accessType") ?? "initializeOnly") ?? .initializeOnly
      
      guard let fieldType = element .attribute (name: "type") else
      {
         return console .warn (t("XML parser error: expected type attribute."))
      }
      
      guard let supportedField = SupportedFields .fields [fieldType] else
      {
         return console .warn (t("XML parser error: unknown field type '%@'.", fieldType))
      }

      guard let name = element .attribute (name: "name") else
      {
         return console .warn (t("XML parser error: expected field name attribute."))
      }

      let field = supportedField .init ()

      if accessType == .initializeOnly || accessType == .inputOutput
      {
         fieldValue (field, element .attribute (name: "value"))

         parents .append (field)
         
         defer { parents .removeLast () }

         childrenElements (element .children)
      }

      node .addUserDefinedField (accessType, name, field)
   }

   private final func routeElement (_ element : XMLElement?)
   {
      do
      {
         guard let element = element else { return }
         
         guard let sourceNodeName = element .attribute (name: "fromNode") else
         {
            return console .warn (t("XML parser error: bad ROUTE statement, expected fromNode attribute."))
         }
         
         guard let sourceField = element .attribute (name: "fromField") else
         {
            return console .warn (t("XML parser error: bad ROUTE statement, expected fromField attribute."))
         }
         
         guard let destinationNodeName = element .attribute (name: "toNode") else
         {
            return console .warn (t("XML parser error: bad ROUTE statement, expected toNode attribute."))
         }
         
         guard let destinationField = element .attribute (name: "toField") else
         {
            return console .warn (t("XML parser error: bad ROUTE statement, expected toField attribute."))
         }

         do
         {
            let sourceNode      = try executionContext .getLocalNode (localName: sourceNodeName)
            let destinationNode = try executionContext .getLocalNode (localName: destinationNodeName)

            try executionContext .addRoute (sourceNode:       sourceNode,
                                            sourceField:      sourceField,
                                            destinationNode:  destinationNode,
                                            destinationField: destinationField)
         }
         catch X3DError .IMPORTED_NODE
         {
            // Imported nodes
         }
      }
      catch
      {
         console .warn (t("XML parser error: %@", error .localizedDescription))
      }
   }

   private final func importElement (_ element : XMLElement?)
   {
      do
      {
         guard let element = element else { return }
         
         guard let inlineNodeName = element .attribute (name: "inlineDEF") else
         {
            return console .warn (t("XML parser error: bad IMPORT statement, expected exportedDEF attribute."))
         }
         
         guard let inlineNode = try executionContext .getNamedNode (name: inlineNodeName) as? Inline else
         {
            throw X3DError .INVALID_X3D (t("XML parser error: node named '%@' is not an Inline node.", inlineNodeName))
         }

         guard let exportedNodeName = element .attribute (name: "importedDEF") ?? element .attribute (name: "exportedDEF") else
         {
            return console .warn (t("XML parser error: bad IMPORT statement, expected importedDEF attribute."))
         }
         
         let importedNodeName = element .attribute (name: "AS") ?? exportedNodeName

         try executionContext .updateImportedNode (inlineNode: inlineNode, exportedName: exportedNodeName, importedName: importedNodeName)
      }
      catch
      {
         console .warn (t("XML parser error: %@", error .localizedDescription))
      }
   }

   private final func exportElement (_ element : XMLElement?)
   {
      do
      {
         guard let element = element else { return }
      
         guard scene == executionContext else { return }
         
         guard let localNodeName = element .attribute (name: "localDEF") else
         {
            return console .warn (t("XML parser error: bad EXPORT statement, expected localDEF attribute."))
         }

         let exportedNodeName = element .attribute (name: "AS") ?? localNodeName
         let localNode        = try executionContext .getNamedNode (name: localNodeName)
         
         try scene .updateExportedNode (exportedName: exportedNodeName, node: localNode)
      }
      catch
      {
         console .warn (t("XML parser error: %@", error .localizedDescription))
      }
   }

   private final func nodeElement (_ element : XMLElement?)
   {
      do
      {
         guard let element = element else { return }
         
         // USE property
      
         if useAttribute (element)
         {
            return
         }
      
         // Node object
      
         let node = try executionContext .createNode (typeName: element .name!, setup: false)

         defAttribute (element, node)

         addNode (element, node)

         parents .append (node)
         
         defer { parents .removeLast () }

         nodeAttributes (element, node)

         childrenElements (element .children)

         if !isInsideProtoDefinition
         {
            node .setup ()
         }
      }
      catch
      {
         console .warn (t("XML parser error: %@", error .localizedDescription))
      }
   }

   private final func useAttribute (_ element : XMLElement) -> Bool
   {
      do
      {
         guard let nodeName = element .attribute (name: "USE") else { return false }
         
         addNode (element, try executionContext .getNamedNode (name: nodeName))
         return true
      }
      catch
      {
         console .warn (t("XML parser error: invalid USE name. %@", error .localizedDescription))
         return false
      }
   }

   private final func defAttribute (_ element : XMLElement, _ node : X3DNode)
   {
      do
      {
         guard let nodeName = element .attribute (name: "DEF") else { return }
         
         if let namedNode = try? executionContext .getNamedNode (name: nodeName)
         {
            try executionContext .updateNamedNode (name: executionContext .getUniqueName (for: nodeName), node: namedNode)
         }

         try executionContext .addNamedNode (name: nodeName, node: node)
      }
      catch
      {
         console .warn (t("XML parser error: invalid DEF name. %@", error .localizedDescription))
      }
   }

   private final func nodeAttributes (_ element : XMLElement, _ node : X3DNode)
   {
      guard let attributes = element .attributes else { return }
      
      for attribute in attributes
      {
         nodeAttribute (attribute, node)
      }
   }
   
   private final func nodeAttribute (_ attribute : XMLNode, _ node : X3DNode)
   {
      guard let name  = attribute .name                  else { return }
      guard let field = try? node .getField (name: name) else { return }

      if field .isInitializable
      {
         fieldValue (field, attribute .stringValue)
      }
   }
   
   private final func addNode (_ element : XMLElement, _ childNode : X3DNode)
   {
      // ExecutionContext

      if parents .isEmpty || parents .last! is X3DProtoDeclaration
      {
         executionContext .rootNodes .append (childNode)
      }

      // Node

      else if let node = parents .last! as? X3DNode
      {
         do
         {
            let containerField = element .attribute (name: "containerField") ?? childNode .getContainerField ()
            let field          = try node .getField (name: containerField)
            
            switch field .getType ()
            {
               case .SFNode: do
               {
                  let sfnode = field as! SFNode <X3DNode>
   
                  sfnode .wrappedValue = childNode
               }
               case .MFNode: do
               {
                  let mfnode = field as! MFNode <X3DNode>
   
                  mfnode .wrappedValue .append (childNode)
               }
               default:
                  break
            }
         }
         catch
         {
            console .warn (error .localizedDescription)
         }
      }

      // Field
   
      else if let field = parents .last! as? X3DField
      {
         switch field .getType ()
         {
            case .SFNode: do
            {
               let sfnode = field as! SFNode <X3DNode>

               sfnode .wrappedValue = childNode
            }
            case .MFNode: do
            {
               let mfnode = field as! MFNode <X3DNode>

               mfnode .wrappedValue .append (childNode)
            }
            default:
               break
         }
      }
   }
   
   private final func fieldValue (_ field : X3DField, _ value : String?)
   {
      switch field .getType ()
      {
         case .SFBool:
            _ = makeParser (value)? .sfboolValueXML (for: field as! SFBool)
         case .SFColor:
            _ = makeParser (value)? .sfcolorValue (for: field as! SFColor)
         case .SFColorRGBA:
            _ = makeParser (value)? .sfcolorrgbaValue (for: field as! SFColorRGBA)
         case .SFDouble:
            _ = makeParser (value)? .sfdoubleValue (for: field as! SFDouble)
         case .SFFloat:
            _ = makeParser (value)? .sffloatValue (for: field as! SFFloat)
         case .SFImage:
            _ = try? makeParser (value)? .sfimageValue (for: field as! SFImage)
         case .SFInt32:
            _ = makeParser (value)? .sfint32Value (for: field as! SFInt32)
         case .SFMatrix3d:
            _ = makeParser (value)? .sfmatrix3dValue (for: field as! SFMatrix3d)
         case .SFMatrix3f:
            _ = makeParser (value)? .sfmatrix3fValue (for: field as! SFMatrix3f)
         case .SFMatrix4d:
            _ = makeParser (value)? .sfmatrix4dValue (for: field as! SFMatrix4d)
         case .SFMatrix4f:
            _ = makeParser (value)? .sfmatrix4fValue (for: field as! SFMatrix4f)
         case .SFNode:
            if value != nil { (field as! SFNode <X3DNode>) .wrappedValue = nil }
         case .SFRotation:
            _ = makeParser (value)? .sfrotationValue (for: field as! SFRotation)
         case .SFTime:
            _ = makeParser (value)? .sftimeValue (for: field as! SFTime)
         case .SFString:
            if let value = value { (field as! SFString) .wrappedValue = value .fromVRMLString () }
         case .SFVec2d:
            _ = makeParser (value)? .sfvec2dValue (for: field as! SFVec2d)
         case .SFVec2f:
            _ = makeParser (value)? .sfvec2fValue (for: field as! SFVec2f)
         case .SFVec3d:
            _ = makeParser (value)? .sfvec3dValue (for: field as! SFVec3d)
         case .SFVec3f:
            _ = makeParser (value)? .sfvec3fValue (for: field as! SFVec3f)
         case .SFVec4d:
            _ = makeParser (value)? .sfvec4dValue (for: field as! SFVec4d)
         case .SFVec4f:
            _ = makeParser (value)? .sfvec4fValue (for: field as! SFVec4f)

         case .MFBool:
            makeParser (value)? .sfboolValuesXML (for: field as! MFBool)
         case .MFColor:
            makeParser (value)? .sfcolorValues (for: field as! MFColor)
         case .MFColorRGBA:
            makeParser (value)? .sfcolorrgbaValues (for: field as! MFColorRGBA)
         case .MFDouble:
            makeParser (value)? .sfdoubleValues (for: field as! MFDouble)
         case .MFFloat:
            makeParser (value)? .sffloatValues (for: field as! MFFloat)
         case .MFImage:
            try? makeParser (value)? .sfimageValues (for: field as! MFImage)
         case .MFInt32:
            makeParser (value)? .sfint32Values (for: field as! MFInt32)
         case .MFMatrix3d:
            makeParser (value)? .sfmatrix3dValues (for: field as! MFMatrix3d)
         case .MFMatrix3f:
            makeParser (value)? .sfmatrix3fValues (for: field as! MFMatrix3f)
         case .MFMatrix4d:
            makeParser (value)? .sfmatrix4dValues (for: field as! MFMatrix4d)
         case .MFMatrix4f:
            makeParser (value)? .sfmatrix4fValues (for: field as! MFMatrix4f)
         case .MFNode:
            (field as! MFNode <X3DNode>) .wrappedValue .removeAll ()
         case .MFRotation:
            makeParser (value)? .sfrotationValues (for: field as! MFRotation)
         case .MFTime:
            makeParser (value)? .sftimeValues (for: field as! MFTime)
         case .MFString:
            makeParser (value)? .sfstringValues (for: field as! MFString)
         case .MFVec2d:
            makeParser (value)? .sfvec2dValues (for: field as! MFVec2d)
         case .MFVec2f:
            makeParser (value)? .sfvec2fValues (for: field as! MFVec2f)
         case .MFVec3d:
            makeParser (value)? .sfvec3dValues (for: field as! MFVec3d)
         case .MFVec3f:
            makeParser (value)? .sfvec3fValues (for: field as! MFVec3f)
         case .MFVec4d:
            makeParser (value)? .sfvec4dValues (for: field as! MFVec4d)
         case .MFVec4f:
            makeParser (value)? .sfvec4fValues (for: field as! MFVec4f)
      }
   }
   
   private final func makeParser (_ value : String?) -> VRMLParser?
   {
      guard let value = value else { return nil }
      
      let parser = VRMLParser (scene: scene, x3dSyntax: value)
      
      if isInsideProtoDefinition
      {
         parser .protos .append (proto)
      }
      
      parser .executionContexts .append (executionContext)
      
      return parser
   }
}

fileprivate extension XMLElement
{
   func attribute (name : String) -> String?
   {
      guard let attribute = attribute (forName: name) else { return nil }
      
      return attribute .stringValue
   }
}
