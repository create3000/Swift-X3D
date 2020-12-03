//
//  File.swift
//  
//
//  Created by Holger Seelig on 07.11.20.
//

internal final class JSONParser :
   X3DParser,
   X3DParserInterface
{
   // Properties
   
   private final var scene : X3DScene
   private final var json  : [String : Any]?
   
   // Construction
   
   internal init (scene : X3DScene, x3dSyntax : String)
   {
      // Set scene and create xml parser.
      self .scene = scene
      self .json  = try? JSONSerialization .jsonObject (with: Data (x3dSyntax .utf8), options: [ ]) as? [String : Any]

      // Init super.
      super .init ()
   }

   // Operations
   
   internal final var isValid : Bool { json != nil }

   internal final func parseIntoScene () throws
   {
      guard let json = json else
      {
         throw X3DError .INVALID_X3D (t("Couldn't read JSON data."))
      }

      x3dObject (json ["X3D"])
   }
   
   // Parse
   
   private final var console : X3DConsole { scene .browser! .console }
   
   private final func x3dObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
      
      executionContexts .append (scene)
      
      defer { executionContexts .removeLast () }
      
      scene .setEncoding ("JSON")
      
      if let _ = string (object ["encoding"])
      {
         // Character encoding
      }
      
      if let profileString = string (object ["@profile"])
      {
         do
         {
            scene .setProfile (try scene .browser! .getProfile (name: profileString))
         }
         catch
         {
            console .warn (error .localizedDescription)
         }
      }
      
      if let versionString = string (object ["@version"])
      {
         scene .setSpecificationVersion (versionString)
      }

      headObject (object ["head"])

      sceneObject (object ["Scene"])
   }
   
   private final func headObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
      
      componentArray (object ["component"])
      unitArray      (object ["unit"])
      metaArray      (object ["meta"])
   }
   
   private final func componentArray (_ objects : Any?)
   {
      guard let objects = objects as? [Any] else { return }

      for object in objects
      {
         componentObject (object)
      }
   }
   
   private final func componentObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
      
      guard let componentName = string (object ["@name"]) else
      {
         return console .warn (t("Expected a component name."))
      }
      
      guard let componentLevel = int32 (object ["@level"]) else
      {
         return console .warn (t("Expected a component support level."))
      }

      do
      {
         scene .addComponent (try scene .browser! .getComponent (name: componentName, level: componentLevel))
      }
      catch
      {
         console .warn (error .localizedDescription)
      }
   }
   
   private final func unitArray (_ objects : Any?)
   {
      guard let objects = objects as? [Any] else { return }
      
      for object in objects
      {
         unitObject (object)
      }
   }
   
   private final func unitObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
      
      guard let categoryName = string (object ["@category"]) else
      {
         return console .warn (t("Expected category name identificator in unit statement."))
      }
      
      guard let category = X3DUnitCategory (categoryName) else
      {
         return console .warn (t("Unkown unit category '%@'.", categoryName))
      }

      guard let unitName = string (object ["@name"]) else
      {
         return console .warn (t("Expected unit name identificator."))
      }
      
      guard let conversionFactor = double (object ["@conversionFactor"]) else
      {
         return console .warn (t("Expected unit conversion factor."))
      }
      
      scene .updateUnit (category, name: unitName, conversionFactor: conversionFactor)
   }

   private final func metaArray (_ objects : Any?)
   {
      guard let objects = objects as? [Any] else { return }
      
      for object in objects
      {
         metaObject (object)
      }
   }

   private final func metaObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }

      guard let metaName = string (object ["@name"]) else
      {
         return console .warn (t("Expected metadata key."))
      }
      
      guard let metaContent = string (object ["@content"]) else
      {
         return console .warn (t("Expected metadata value."))
      }
      
      scene .metadata [metaName, default: [ ]] .append (metaContent)
   }

   private final func sceneObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
      
      childrenArray (object ["-children"], scene .$rootNodes)
   }

   private final func childrenArray (_ objects : Any?, _ field : MFNode <X3DNode>)
   {
      guard let objects = objects as? [Any] else { return }
      
      for object in objects
      {
         let (success, node) = childObject (object)
         
         if success
         {
            field .wrappedValue .append (node)
         }
      }
   }

   private final func childObject (_ object : Any?) -> (Bool, X3DNode?)
   {
      guard let object = object as? [String : Any] else { return (false, nil) }
            
      for (key, value) in object
      {
         switch key
         {
            case "ExternProtoDeclare":
               externProtoDeclareObject (value)
            case "ProtoDeclare":
               protoDeclareObject (value)
            case "ROUTE":
               routeObject (value)
            case "IMPORT":
               importObject (value)
            case "EXPORT":
               exportObject (value)
            default:
               return (true, nodeObject (value, nodeType: key))
         }
      }
      
      return (false, nil)
   }

   private final func externProtoDeclareObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
      
      guard let name = string (object ["@name"]) else
      {
         return console .warn (t("Expected @name property."))
      }
      
      let URLList = MFString ()
      
      guard mfstringValue (object ["@url"], URLList) else
      {
         return console .warn (t("Expected @url property."))
      }
      
      let externproto = executionContext .createExternProtoDeclaration (name: name, interfaceDeclarations: [ ], url: [String] (URLList .wrappedValue), setup: false)

      fieldArray (object ["field"], externproto)

      try? executionContext .updateExternProtoDeclaration (name: name, externproto: externproto)
      
      externproto .setup ()
   }

   private final func protoDeclareObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
      
      guard let name = string (object ["@name"]) else
      {
         return console .warn (t("Expected @name property."))
      }

      let proto = executionContext .createProtoDeclaration (name: name, interfaceDeclarations: [ ], setup: false)

      protoInterfaceObject (object ["ProtoInterface"], proto)
      
      protos            .append (proto)
      executionContexts .append (proto .getBody ())

      protoBodyObject (object ["ProtoBody"], proto)

      protos            .removeLast ()
      executionContexts .removeLast ()

      try? executionContext .updateProtoDeclaration (name: name, proto: proto)
      
      proto .setup ()
   }
   
   private final func protoInterfaceObject (_ object : Any?, _ proto : X3DProtoDeclaration)
   {
      guard let object = object as? [String : Any] else { return }
      
      fieldArray (object ["field"], proto)
   }
   
   private final func protoBodyObject (_ object : Any?, _ proto : X3DProtoDeclaration)
   {
      guard let object = object as? [String : Any] else { return }
      
      childrenArray (object ["-children"], proto .getBody () .$rootNodes)
   }

   private final func routeObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
      
      guard let fromNodeName = string (object ["@fromNode"]) else
      {
         return console .warn (t("Expected @fromNode property."))
      }
      
      guard let fromFieldName = string (object ["@fromField"]) else
      {
         return console .warn (t("Expected @fromField property."))
      }
      
      guard let toNodeName = string (object ["@toNode"]) else
      {
         return console .warn (t("Expected @toNode property."))
      }
      
      guard let toFieldName = string (object ["@toField"]) else
      {
         return console .warn (t("Expected @toField property."))
      }
      
      do
      {
         let fromNode = try executionContext .getLocalNode (localName: fromNodeName)
         let toNode   = try executionContext .getLocalNode (localName: toNodeName)

         try executionContext .addRoute (sourceNode: fromNode,
                                         sourceField: fromFieldName,
                                         destinationNode: toNode,
                                         destinationField: toFieldName)
      }
      catch
      {
         console .warn (error .localizedDescription)
      }
   }

   private final func importObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
      
      guard let inlineDEF = string (object ["@inlineDEF"]) else
      {
         return console .warn (t("Expected @inlineDEF property."))
      }
      
      guard let inlineNode = try? executionContext .getNamedNode (name: inlineDEF) as? Inline else
      {
         return console .warn (t("Inline node named '%@' not found.", inlineDEF))
      }
      
      guard let importedDEF = string (object ["@importedDEF"]) else
      {
         return console .warn (t("Expected @importedDEF property."))
      }
      
      let ASName = string (object ["@AS"]) ?? importedDEF
      
      do
      {
         try scene .updateImportedNode (inlineNode: inlineNode, exportedName: importedDEF, importedName: ASName)
      }
      catch
      {
         console .warn (error .localizedDescription)
      }
   }

   private final func exportObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
      
      guard scene == executionContext else { return }
      
      guard let localDEF = string (object ["@localDEF"]) else
      {
         return console .warn (t("Expected @localDEF property."))
      }
      
      let ASName = string (object ["@AS"]) ?? localDEF
      
      do
      {
         let node = try scene .getLocalNode (localName: localDEF)

         try scene .updateExportedNode (exportedName: ASName, node: node)
      }
      catch
      {
         console .warn (error .localizedDescription)
      }
   }

   private final func nodeObject (_ object : Any?, nodeType : String) -> X3DNode?
   {
      guard let object = object as? [String : Any] else { return nil }
      
      // USE property

      do
      {
         if let nodeName = string (object ["@USE"])
         {
            return try executionContext .getNamedNode (name: nodeName)
         }
      }
      catch
      {
         console .warn (error .localizedDescription)
         return nil
      }

      // Node object

      var prototypeInstance = false
      var node : X3DNode? = nil

      do
      {
         if nodeType == "ProtoInstance"
         {
            guard let name = string (object ["@name"]) else
            {
               console .warn (t("Couldn't create proto instance, no name given."))
               return nil
            }
            
            prototypeInstance = true
            node              = try executionContext .createProto (typeName: name, setup: false)
         }
         else
         {
            node = try executionContext .createNode (typeName: nodeType, setup: false)
         }
      }
      catch
      {
         console .warn (error .localizedDescription)
         return nil
      }
      
      // Node name
      
      do
      {
         if let nodeName = string (object ["@DEF"])
         {
            if !nodeName .isEmpty
            {
               if let namedNode = try? executionContext .getNamedNode (name: nodeName)
               {
                  try executionContext .updateNamedNode (name: executionContext .getUniqueName (for: nodeName),
                                                         node: namedNode)
               }

               try executionContext .addNamedNode (name: nodeName, node: node!)
            }
         }
      }
      catch
      {
         console .warn (t("Invalid DEF name. %@", error .localizedDescription))
      }

      // Fields

      if prototypeInstance
      {
         let metadata = try! node! .getField (name: "metadata")

         if metadata .isInitializable && metadata .getType () == .SFNode
         {
            _ = fieldValueValue (object ["-metadata"], metadata)
         }
         
         fieldValueArray (object ["fieldValue"], node!)
      }
      else
      {
         // Predefined fields
         nodeFieldsObject (object, node!)
      }

      if node! .canUserDefinedFields
      {
         fieldArray (object ["field"], node!)
      }

      sourceTextArray (object ["#sourceText"], node!)

      if isInsideProtoDefinition
      {
         isObject (object ["IS"], node!)
      }
      else
      {
         // After fields are parsed initialize node.
         node! .setup ()
      }

      return node
   }

   private final func nodeFieldsObject (_ object : [String : Any], _ node : X3DNode)
   {
      for field in node .getPreDefinedFields ()
      {
         guard field .isInitializable else { continue }

         switch field .getType ()
         {
            case .SFNode, .MFNode:
               _ = fieldValueValue (object ["-" + field .getName ()], field)
            default:
               _ = fieldValueValue (object ["@" + field .getName ()], field)
         }
      }
   }

   private final func sourceTextArray (_ objects : Any?, _ node : X3DNode)
   {
      guard let objects = objects as? [Any] else { return }
      
      guard let sourceText = node .getSourceText () else { return }
      
      var lines = ""
      
      for line in objects
      {
         lines += string (line) ?? ""
         lines += "\n"
      }
      
      sourceText .wrappedValue .removeAll ()
      sourceText .wrappedValue .append (lines)
   }

   private final func fieldValueArray (_ objects : Any?, _ node : X3DNode)
   {
      guard let objects = objects as? [Any] else { return }
      
      for object in objects
      {
         fieldValueObject (object, node)
      }
   }

   private final func fieldValueObject (_ object : Any?, _ node : X3DNode)
   {
      guard let object = object as? [String : Any] else { return }
      
      guard let name = string (object ["@name"]) else
      {
         return console .warn (t("Expected @name property."))
      }
      
      do
      {
         let field = try node .getField (name: name)
         
         guard field .isInitializable else { return }
         
         switch field .getType ()
         {
            case .SFNode: do
            {
               let sfnode = field as! SFNode <X3DNode>
               let value  = MFNode <X3DNode> ()

               if fieldValueValue (object ["-children"], value)
               {
                  if !value .wrappedValue .isEmpty
                  {
                     sfnode .wrappedValue = value .wrappedValue [0]
                  }
               }
            }
            case .MFNode:
               _ = fieldValueValue (object ["-children"], field)
            default:
               _ = fieldValueValue (object ["@value"], field)
         }
      }
      catch
      {
         console .warn (error .localizedDescription)
      }
   }

   private final func fieldArray (_ objects : Any?, _ node : X3DBaseNode)
   {
      guard let objects = objects as? [Any] else { return }
      
      for object in objects
      {
         fieldObject (object, node)
      }
   }

   private final func fieldObject (_ object : Any?, _ node : X3DBaseNode)
   {
      guard let object = object as? [String : Any] else { return }
      
      guard let accessType = X3DAccessType (string (object ["@accessType"]) ?? "") else
      {
         return console .warn (t("Expected @accessType property."))
      }
      
      guard let type = string (object ["@type"]) else
      {
         return console .warn (t("Expected @type property."))
      }
      
      guard let supportedField = SupportedFields .fields [type] else
      {
         return console .warn (t("Expected a valid field type."))
      }

      guard let name = string (object ["@name"]) else
      {
         return console .warn (t("Expected @name property."))
      }
      
      let field = supportedField .init ()
      
      node .addUserDefinedField (accessType, name, field)
      
      guard field .isInitializable else { return }

      switch field .getType ()
      {
         case .SFNode: do
         {
            let sfnode = field as! SFNode <X3DNode>
            let value  = MFNode <X3DNode> ()

            if fieldValueValue (object ["-children"], value)
            {
               if !value .wrappedValue .isEmpty
               {
                  sfnode .wrappedValue = value .wrappedValue [0]
               }
            }
         }
         case .MFNode:
            _ = fieldValueValue (object ["-children"], field)
         default:
            _ = fieldValueValue (object ["@value"], field)
      }
   }

   private final func isObject (_ object : Any?, _ node : X3DNode)
   {
      guard let object = object as? [String : Any] else { return }
      
      connectArray (object ["connect"], node)
   }

   private final func connectArray (_ objects : Any?, _ node : X3DNode)
   {
      guard let objects = objects as? [Any] else { return }
      
      for object in objects
      {
         connectObject (object, node)
      }
   }

   private final func connectObject (_ object : Any?, _ node : X3DNode)
   {
      guard let object = object as? [String : Any] else { return }
      
      guard let nodeFieldName = string (object ["@nodeField"]) else
      {
         return console .warn (t("Expected @nodeField property."))
      }
      
      guard let protoFieldName = string (object ["@protoField"]) else
      {
         return console .warn (t("Expected @protoField property."))
      }
      
      do
      {
         let nodeField  = try node .getField (name: nodeFieldName)
         let protoField = try proto .getField (name: protoFieldName)
         
         guard nodeField .getType () == protoField .getType () else
         {
            return console .warn (t("Field '%@' and '%@' in PROTO %@ have different types.", nodeField .getName (), protoField .getName (), executionContext .getName ()))
         }
         
         guard protoField .isReference (for: nodeField .getAccessType ()) else
         {
            return console .warn (t("Field '%@' and '%@' in PROTO %@ are incompatible as an IS mapping.", nodeField .getName (), protoField .getName (), executionContext .getName ()))
         }
         
         nodeField .addReference (to: protoField)
      }
      catch
      {
         console .warn (error .localizedDescription)
      }
   }

   private final func fieldValueValue (_ object : Any?, _ field : X3DField) -> Bool
   {
      guard object != nil else { return false }
      
      switch field .getType ()
      {
         case .SFBool:      return sfboolValue       (object, field as! SFBool)
         case .SFColor:     return sfcolorValue      (object, field as! SFColor)
         case .SFColorRGBA: return sfcolorrgbaValue  (object, field as! SFColorRGBA)
         case .SFDouble:    return sfdoubleValue     (object, field as! SFDouble)
         case .SFFloat:     return sffloatValue      (object, field as! SFFloat)
         case .SFImage:     return sfimageValue      (object, field as! SFImage)
         case .SFInt32:     return sfint32Value      (object, field as! SFInt32)
         case .SFMatrix3d:  return sfmatrix3dValue   (object, field as! SFMatrix3d)
         case .SFMatrix3f:  return sfmatrix3fValue   (object, field as! SFMatrix3f)
         case .SFMatrix4d:  return sfmatrix4dValue   (object, field as! SFMatrix4d)
         case .SFMatrix4f:  return sfmatrix4fValue   (object, field as! SFMatrix4f)
         case .SFNode:      return sfnodeValue       (object, field as! SFNode <X3DNode>)
         case .SFRotation:  return sfrotationValue   (object, field as! SFRotation)
         case .SFString:    return sfstringValue     (object, field as! SFString)
         case .SFTime:      return sftimeValue       (object, field as! SFTime)
         case .SFVec2d:     return sfvec2dValue      (object, field as! SFVec2d)
         case .SFVec2f:     return sfvec2fValue      (object, field as! SFVec2f)
         case .SFVec3d:     return sfvec3dValue      (object, field as! SFVec3d)
         case .SFVec3f:     return sfvec3fValue      (object, field as! SFVec3f)
         case .SFVec4d:     return sfvec4dValue      (object, field as! SFVec4d)
         case .SFVec4f:     return sfvec4fValue      (object, field as! SFVec4f)

         case .MFBool:      return mfboolValue       (object, field as! MFBool)
         case .MFColor:     return mfcolorValue      (object, field as! MFColor)
         case .MFColorRGBA: return mfcolorrgbaValue  (object, field as! MFColorRGBA)
         case .MFDouble:    return mfdoubleValue     (object, field as! MFDouble)
         case .MFFloat:     return mffloatValue      (object, field as! MFFloat)
         case .MFImage:     return mfimageValue      (object, field as! MFImage)
         case .MFInt32:     return mfint32Value      (object, field as! MFInt32)
         case .MFMatrix3d:  return mfmatrix3dValue   (object, field as! MFMatrix3d)
         case .MFMatrix3f:  return mfmatrix3fValue   (object, field as! MFMatrix3f)
         case .MFMatrix4d:  return mfmatrix4dValue   (object, field as! MFMatrix4d)
         case .MFMatrix4f:  return mfmatrix4fValue   (object, field as! MFMatrix4f)
         case .MFNode:      return mfnodeValue       (object, field as! MFNode <X3DNode>)
         case .MFRotation:  return mfrotationValue   (object, field as! MFRotation)
         case .MFString:    return mfstringValue     (object, field as! MFString)
         case .MFTime:      return mftimeValue       (object, field as! MFTime)
         case .MFVec2d:     return mfvec2dValue      (object, field as! MFVec2d)
         case .MFVec2f:     return mfvec2fValue      (object, field as! MFVec2f)
         case .MFVec3d:     return mfvec3dValue      (object, field as! MFVec3d)
         case .MFVec3f:     return mfvec3fValue      (object, field as! MFVec3f)
         case .MFVec4d:     return mfvec4dValue      (object, field as! MFVec4d)
         case .MFVec4f:     return mfvec4fValue      (object, field as! MFVec4f)
      }
   }
   
   private final func bool (_ object : Any?) -> Bool?
   {
      return object as? Bool
   }
   
   private final func double (_ object : Any?) -> Double?
   {
      if let object = object as? Double { return object }
      if let object = object as? Float  { return Double (object) }
      if let object = object as? Int32  { return Double (object) }
      if let object = object as? Int    { return Double (object) }

      return nil
   }

   private final func float (_ object : Any?) -> Float?
   {
      if let object = object as? Double { return Float (object) }
      if let object = object as? Float  { return object }
      if let object = object as? Int32  { return Float (object) }
      if let object = object as? Int    { return Float (object) }

      return nil
   }
   
   private final func int32 (_ object : Any?) -> Int32?
   {
      if let object = object as? Int32  { return object }
      if let object = object as? Int    { return Int32 (object) }
      if let object = object as? Double { return Int32 (object) }
      if let object = object as? Float  { return Int32 (object) }
      
      return nil
   }
   
   private final func string (_ object : Any?) -> String?
   {
      return object as? String
   }

   private final func sfboolValue (_ object : Any?, _ field : SFBool) -> Bool
   {
      field .wrappedValue = bool (object) ?? false
      
      return true
   }
   
   private final func mfboolValue (_ objects : Any?, _ field : MFBool) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: objects .map { bool ($0) ?? false })
      
      return true
   }
   
   private final func sfcolorValue (_ objects : Any?, _ field : SFColor) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      guard objects .count == 3 else { return false }

      field .wrappedValue = Color3f (float (objects [0]) ?? 0,
                                     float (objects [1]) ?? 0,
                                     float (objects [2]) ?? 0)
      
      return true
   }
   
   private final func mfcolorValue (_ objects : Any?, _ field : MFColor) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      var value = ContiguousArray <Color3f> ()
      
      for i in stride (from: 0, to: objects .count, by: 3)
      {
         value .append (Color3f (float (objects [i + 0]) ?? 0,
                                 float (objects [i + 1]) ?? 0,
                                 float (objects [i + 2]) ?? 0))
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }
   
   private final func sfcolorrgbaValue (_ objects : Any?, _ field : SFColorRGBA) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      guard objects .count == 4 else { return false }

      field .wrappedValue = Color4f (float (objects [0]) ?? 0,
                                     float (objects [1]) ?? 0,
                                     float (objects [2]) ?? 0,
                                     float (objects [3]) ?? 0)
      
      return true
   }
   
   private final func mfcolorrgbaValue (_ objects : Any?, _ field : MFColorRGBA) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      var value = ContiguousArray <Color4f> ()

      for i in stride (from: 0, to: objects .count, by: 4)
      {
         value .append (Color4f (float (objects [i + 0]) ?? 0,
                                 float (objects [i + 1]) ?? 0,
                                 float (objects [i + 2]) ?? 0,
                                 float (objects [i + 3]) ?? 0))
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }

   private final func sfdoubleValue (_ object : Any?, _ field : SFDouble) -> Bool
   {
      field .wrappedValue = fromUnit (field .unit, value: double (object) ?? 0)
      
      return true
   }
   
   private final func mfdoubleValue (_ objects : Any?, _ field : MFDouble) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      let unit = field .unit
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: objects .map { fromUnit (unit, value: double ($0) ?? 0)})
      
      return true
   }
   
   private final func sffloatValue (_ object : Any?, _ field : SFFloat) -> Bool
   {
      field .wrappedValue = fromUnit (field .unit, value: float (object) ?? 0)

      return true
   }
   
   private final func mffloatValue (_ objects : Any?, _ field : MFFloat) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      let unit = field .unit
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: objects .map { fromUnit (unit, value: float ($0) ?? 0)})

      return true
   }
   
   private final func sfimageValue (_ objects : Any?, _ field : SFImage) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      guard objects .count >= 3 else { return false }
      
      let array = field .wrappedValue .$array
      
      field .wrappedValue .width  = int32 (objects [0]) ?? 0
      field .wrappedValue .height = int32 (objects [1]) ?? 0
      field .wrappedValue .comp   = int32 (objects [2]) ?? 0

      for i in stride (from: 3, to: min (3 + array .wrappedValue .count, objects .count), by: 1)
      {
         array .wrappedValue [i - 3] = int32 (objects [i]) ?? 0
      }
      
      return true
   }
   
   private final func mfimageValue (_ objects : Any?, _ field : MFImage) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      field .wrappedValue .removeAll ()
      
      var i = 0
      
      while objects .count >= i + 3
      {
         let element = SFImage ()
         let array   = element .wrappedValue .$array
         let first   = i + 3

         element .wrappedValue .width  = int32 (objects [i + 0]) ?? 0
         element .wrappedValue .height = int32 (objects [i + 1]) ?? 0
         element .wrappedValue .comp   = int32 (objects [i + 2]) ?? 0
         
         for ii in stride (from: first, to: min (first + array .wrappedValue .count, objects .count), by: 1)
         {
            array .wrappedValue [ii - first] = int32 (objects [i + ii]) ?? 0
         }
         
         field .wrappedValue .append (element .wrappedValue)
         
         i += 3 + array .wrappedValue .count
      }
      
      return true
   }

   private final func sfint32Value (_ object : Any?, _ field : SFInt32) -> Bool
   {
      field .wrappedValue = int32 (object) ?? 0
      
      return true
   }
   
   private final func mfint32Value (_ objects : Any?, _ field : MFInt32) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: objects .map { int32 ($0) ?? 0 })
      
      return true
   }

   private final func sfmatrix3dValue (_ objects : Any?, _ field : SFMatrix3d) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
     
      guard objects .count == 9 else { return false }
     
      field .wrappedValue = Matrix3d (columns: (Vector3d (double (objects [0]) ?? 0,
                                                          double (objects [1]) ?? 0,
                                                          double (objects [2]) ?? 0),
                                                Vector3d (double (objects [3]) ?? 0,
                                                          double (objects [4]) ?? 0,
                                                          double (objects [5]) ?? 0),
                                                Vector3d (double (objects [6]) ?? 0,
                                                          double (objects [7]) ?? 0,
                                                          double (objects [8]) ?? 0)))
     
      return true
   }

   private final func mfmatrix3dValue (_ objects : Any?, _ field : MFMatrix3d) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
     
      var value = ContiguousArray <Matrix3d> ()
     
      for i in stride (from: 0, to: objects .count, by: 9)
      {
         value .append (Matrix3d (columns: (Vector3d (double (objects [i + 0]) ?? 0,
                                                      double (objects [i + 1]) ?? 0,
                                                      double (objects [i + 2]) ?? 0),
                                            Vector3d (double (objects [i + 3]) ?? 0,
                                                      double (objects [i + 4]) ?? 0,
                                                      double (objects [i + 5]) ?? 0),
                                            Vector3d (double (objects [i + 6]) ?? 0,
                                                      double (objects [i + 7]) ?? 0,
                                                      double (objects [i + 8]) ?? 0))))
      }
     
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }

   private final func sfmatrix3fValue (_ objects : Any?, _ field : SFMatrix3f) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
     
      guard objects .count == 9 else { return false }
     
      field .wrappedValue = Matrix3f (columns: (Vector3f (float (objects [0]) ?? 0,
                                                          float (objects [1]) ?? 0,
                                                          float (objects [2]) ?? 0),
                                                Vector3f (float (objects [3]) ?? 0,
                                                          float (objects [4]) ?? 0,
                                                          float (objects [5]) ?? 0),
                                                Vector3f (float (objects [6]) ?? 0,
                                                          float (objects [7]) ?? 0,
                                                          float (objects [8]) ?? 0)))
     
      return true
   }

   private final func mfmatrix3fValue (_ objects : Any?, _ field : MFMatrix3f) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
     
      var value = ContiguousArray <Matrix3f> ()
     
      for i in stride (from: 0, to: objects .count, by: 9)
      {
         value .append (Matrix3f (columns: (Vector3f (float (objects [i + 0]) ?? 0,
                                                      float (objects [i + 1]) ?? 0,
                                                      float (objects [i + 2]) ?? 0),
                                            Vector3f (float (objects [i + 3]) ?? 0,
                                                      float (objects [i + 4]) ?? 0,
                                                      float (objects [i + 5]) ?? 0),
                                            Vector3f (float (objects [i + 6]) ?? 0,
                                                      float (objects [i + 7]) ?? 0,
                                                      float (objects [i + 8]) ?? 0))))
      }
     
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }

   private final func sfmatrix4dValue (_ objects : Any?, _ field : SFMatrix4d) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
     
      guard objects .count == 16 else { return false }
     
      field .wrappedValue = Matrix4d (columns: (Vector4d (double (objects [ 0]) ?? 0,
                                                          double (objects [ 1]) ?? 0,
                                                          double (objects [ 2]) ?? 0,
                                                          double (objects [ 3]) ?? 0),
                                                Vector4d (double (objects [ 4]) ?? 0,
                                                          double (objects [ 5]) ?? 0,
                                                          double (objects [ 6]) ?? 0,
                                                          double (objects [ 7]) ?? 0),
                                                Vector4d (double (objects [ 8]) ?? 0,
                                                          double (objects [ 9]) ?? 0,
                                                          double (objects [10]) ?? 0,
                                                          double (objects [11]) ?? 0),
                                                Vector4d (double (objects [12]) ?? 0,
                                                          double (objects [13]) ?? 0,
                                                          double (objects [14]) ?? 0,
                                                          double (objects [15]) ?? 0)))
     
      return true
   }

   private final func mfmatrix4dValue (_ objects : Any?, _ field : MFMatrix4d) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
     
      var value = ContiguousArray <Matrix4d> ()
     
      for i in stride (from: 0, to: objects .count, by: 16)
      {
         value .append (Matrix4d (columns: (Vector4d (double (objects [i +  0]) ?? 0,
                                                      double (objects [i +  1]) ?? 0,
                                                      double (objects [i +  2]) ?? 0,
                                                      double (objects [i +  3]) ?? 0),
                                            Vector4d (double (objects [i +  4]) ?? 0,
                                                      double (objects [i +  5]) ?? 0,
                                                      double (objects [i +  6]) ?? 0,
                                                      double (objects [i +  7]) ?? 0),
                                            Vector4d (double (objects [i +  8]) ?? 0,
                                                      double (objects [i +  9]) ?? 0,
                                                      double (objects [i + 10]) ?? 0,
                                                      double (objects [i + 11]) ?? 0),
                                            Vector4d (double (objects [i + 12]) ?? 0,
                                                      double (objects [i + 13]) ?? 0,
                                                      double (objects [i + 14]) ?? 0,
                                                      double (objects [i + 15]) ?? 0))))
      }
     
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }

   private final func sfmatrix4fValue (_ objects : Any?, _ field : SFMatrix4f) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
     
      guard objects .count == 16 else { return false }
     
      field .wrappedValue = Matrix4f (columns: (Vector4f (float (objects [ 0]) ?? 0,
                                                          float (objects [ 1]) ?? 0,
                                                          float (objects [ 2]) ?? 0,
                                                          float (objects [ 3]) ?? 0),
                                                Vector4f (float (objects [ 4]) ?? 0,
                                                          float (objects [ 5]) ?? 0,
                                                          float (objects [ 6]) ?? 0,
                                                          float (objects [ 7]) ?? 0),
                                                Vector4f (float (objects [ 8]) ?? 0,
                                                          float (objects [ 9]) ?? 0,
                                                          float (objects [10]) ?? 0,
                                                          float (objects [11]) ?? 0),
                                                Vector4f (float (objects [12]) ?? 0,
                                                          float (objects [13]) ?? 0,
                                                          float (objects [14]) ?? 0,
                                                          float (objects [15]) ?? 0)))
     
      return true
   }

   private final func mfmatrix4fValue (_ objects : Any?, _ field : MFMatrix4f) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
     
      var value = ContiguousArray <Matrix4f> ()
     
      for i in stride (from: 0, to: objects .count, by: 16)
      {
         value .append (Matrix4f (columns: (Vector4f (float (objects [i +  0]) ?? 0,
                                                      float (objects [i +  1]) ?? 0,
                                                      float (objects [i +  2]) ?? 0,
                                                      float (objects [i +  3]) ?? 0),
                                            Vector4f (float (objects [i +  4]) ?? 0,
                                                      float (objects [i +  5]) ?? 0,
                                                      float (objects [i +  6]) ?? 0,
                                                      float (objects [i +  7]) ?? 0),
                                            Vector4f (float (objects [i +  8]) ?? 0,
                                                      float (objects [i +  9]) ?? 0,
                                                      float (objects [i + 10]) ?? 0,
                                                      float (objects [i + 11]) ?? 0),
                                            Vector4f (float (objects [i + 12]) ?? 0,
                                                      float (objects [i + 13]) ?? 0,
                                                      float (objects [i + 14]) ?? 0,
                                                      float (objects [i + 15]) ?? 0))))
      }
     
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }
   
   private final func sfnodeValue (_ object : Any?, _ field : SFNode <X3DNode>) -> Bool
   {
      let (success, node) = childObject (object)
      
      if success
      {
         field .wrappedValue = node
         return true
      }
      else
      {
         field .wrappedValue = nil
         return true
      }
   }
   
   private final func mfnodeValue (_ objects : Any?, _ field : MFNode <X3DNode>) -> Bool
   {
      field .wrappedValue .removeAll ()

      childrenArray (objects, field)

      return true
   }

   private final func sfrotationValue (_ objects : Any?, _ field : SFRotation) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
        
      guard objects .count == 4 else { return false }
        
      field .wrappedValue = Rotation4f (float (objects [0]) ?? 0,
                                        float (objects [1]) ?? 0,
                                        float (objects [2]) ?? 0,
                                        fromUnit (.angle, value: float (objects [3]) ?? 0))
        
      return true
   }

   private final func mfrotationValue (_ objects : Any?, _ field : MFRotation) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
        
      var value = ContiguousArray <Rotation4f> ()
        
      for i in stride (from: 0, to: objects .count, by: 4)
      {
         value .append (Rotation4f (float (objects [i + 0]) ?? 0,
                                    float (objects [i + 1]) ?? 0,
                                    float (objects [i + 2]) ?? 0,
                                    fromUnit (.angle, value: float (objects [i + 3]) ?? 0)))
      }
        
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }

   private final func sfstringValue (_ object : Any?, _ field : SFString) -> Bool
   {
      field .wrappedValue = string (object) ?? ""
      
      return true
   }
   
   private final func mfstringValue (_ objects : Any?, _ field : MFString) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: objects .map { string ($0) ?? "" })
      
      return true
   }
   
   private final func sftimeValue (_ object : Any?, _ field : SFTime) -> Bool
   {
      field .wrappedValue = double (object) ?? 0
      
      return true
   }
   
   private final func mftimeValue (_ objects : Any?, _ field : MFTime) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: objects .map { double ($0) ?? 0 })
      
      return true
   }
   
   private final func sfvec2dValue (_ objects : Any?, _ field : SFVec2d) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      guard objects .count == 2 else { return false }

      let unit = field .unit
      
      field .wrappedValue = Vector2d (fromUnit (unit, value: double (objects [0]) ?? 0),
                                      fromUnit (unit, value: double (objects [1]) ?? 0))

      return true
   }
   
   private final func mfvec2dValue (_ objects : Any?, _ field : MFVec2d) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      var value = ContiguousArray <Vector2d> ()
      let unit  = field .unit

      for i in stride (from: 0, to: objects .count, by: 2)
      {
         value .append (Vector2d (fromUnit (unit, value: double (objects [i + 0]) ?? 0),
                                  fromUnit (unit, value: double (objects [i + 1]) ?? 0)))
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }
   
   private final func sfvec2fValue (_ objects : Any?, _ field : SFVec2f) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      guard objects .count == 2 else { return false }

      let unit = field .unit
      
      field .wrappedValue = Vector2f (fromUnit (unit, value: float (objects [0]) ?? 0),
                                      fromUnit (unit, value: float (objects [1]) ?? 0))

      return true
   }
   
   private final func mfvec2fValue (_ objects : Any?, _ field : MFVec2f) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      var value = ContiguousArray <Vector2f> ()
      let unit  = field .unit

      for i in stride (from: 0, to: objects .count, by: 2)
      {
         value .append (Vector2f (fromUnit (unit, value: float (objects [i + 0]) ?? 0),
                                  fromUnit (unit, value: float (objects [i + 1]) ?? 0)))
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }

   private final func sfvec3dValue (_ objects : Any?, _ field : SFVec3d) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      guard objects .count == 3 else { return false }

      let unit = field .unit
      
      field .wrappedValue = Vector3d (fromUnit (unit, value: double (objects [0]) ?? 0),
                                      fromUnit (unit, value: double (objects [1]) ?? 0),
                                      fromUnit (unit, value: double (objects [2]) ?? 0))

      return true
   }
   
   private final func mfvec3dValue (_ objects : Any?, _ field : MFVec3d) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      var value = ContiguousArray <Vector3d> ()
      let unit  = field .unit
      
      for i in stride (from: 0, to: objects .count, by: 3)
      {
         value .append (Vector3d (fromUnit (unit, value: double (objects [i + 0]) ?? 0),
                                  fromUnit (unit, value: double (objects [i + 1]) ?? 0),
                                  fromUnit (unit, value: double (objects [i + 2]) ?? 0)))
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }

   private final func sfvec3fValue (_ objects : Any?, _ field : SFVec3f) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      guard objects .count == 3 else { return false }

      let unit = field .unit
      
      field .wrappedValue = Vector3f (fromUnit (unit, value: float (objects [0]) ?? 0),
                                      fromUnit (unit, value: float (objects [1]) ?? 0),
                                      fromUnit (unit, value: float (objects [2]) ?? 0))

      return true
   }
   
   private final func mfvec3fValue (_ objects : Any?, _ field : MFVec3f) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      var value = ContiguousArray <Vector3f> ()
      let unit  = field .unit
      
      for i in stride (from: 0, to: objects .count, by: 3)
      {
         value .append (Vector3f (fromUnit (unit, value: float (objects [i + 0]) ?? 0),
                                  fromUnit (unit, value: float (objects [i + 1]) ?? 0),
                                  fromUnit (unit, value: float (objects [i + 2]) ?? 0)))
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }

   private final func sfvec4dValue (_ objects : Any?, _ field : SFVec4d) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      guard objects .count == 4 else { return false }

      let unit = field .unit
      
      field .wrappedValue = Vector4d (fromUnit (unit, value: double (objects [0]) ?? 0),
                                      fromUnit (unit, value: double (objects [1]) ?? 0),
                                      fromUnit (unit, value: double (objects [2]) ?? 0),
                                      fromUnit (unit, value: double (objects [3]) ?? 0))

      return true
   }
   
   private final func mfvec4dValue (_ objects : Any?, _ field : MFVec4d) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      var value = ContiguousArray <Vector4d> ()
      let unit  = field .unit
      
      for i in stride (from: 0, to: objects .count, by: 4)
      {
         value .append (Vector4d (fromUnit (unit, value: double (objects [i + 0]) ?? 0),
                                  fromUnit (unit, value: double (objects [i + 1]) ?? 0),
                                  fromUnit (unit, value: double (objects [i + 2]) ?? 0),
                                  fromUnit (unit, value: double (objects [i + 3]) ?? 0)))
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }
 
   private final func sfvec4fValue (_ objects : Any?, _ field : SFVec4f) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      guard objects .count == 4 else { return false }

      let unit = field .unit
      
      field .wrappedValue = Vector4f (fromUnit (unit, value: float (objects [0]) ?? 0),
                                      fromUnit (unit, value: float (objects [1]) ?? 0),
                                      fromUnit (unit, value: float (objects [2]) ?? 0),
                                      fromUnit (unit, value: float (objects [3]) ?? 0))
      
      return true
   }
   
   private final func mfvec4fValue (_ objects : Any?, _ field : MFVec4f) -> Bool
   {
      guard let objects = objects as? [Any] else { return false }
      
      var value = ContiguousArray <Vector4f> ()
      let unit  = field .unit
      
      for i in stride (from: 0, to: objects .count, by: 4)
      {
         value .append (Vector4f (fromUnit (unit, value: float (objects [i + 0]) ?? 0),
                                  fromUnit (unit, value: float (objects [i + 1]) ?? 0),
                                  fromUnit (unit, value: float (objects [i + 2]) ?? 0),
                                  fromUnit (unit, value: float (objects [i + 3]) ?? 0)))
      }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: value)

      return true
   }
}
