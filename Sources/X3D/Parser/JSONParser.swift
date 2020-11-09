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
      
      if let _ = object ["encoding"] as? String
      {
         
      }
      
      if let profileString = object ["@profile"] as? String
      {
         do
         {
            scene .profile = try scene .browser! .getProfile (name: profileString)
         }
         catch
         {
            console .warn (error .localizedDescription)
         }
      }
      
      if let versionString = object ["@version"] as? String
      {
         scene .specificationVersion = versionString
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
      
      guard let componentName = object ["@name"] as? String else
      {
         return console .warn (t("Expected a component name."))
      }
      
      guard let componentLevel = object ["@level"] as? Int32 else
      {
         return console .warn (t("Expected a component support level."))
      }

      do
      {
         scene .components .append (try scene .browser! .getComponent (name: componentName, level: componentLevel))
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
      
      guard let categoryName = object ["@category"] as? String else
      {
         return console .warn (t("Expected category name identificator in unit statement."))
      }
      
      guard let category = X3DUnitCategory (categoryName) else
      {
         return console .warn (t("Unkown unit category '%@'.", categoryName))
      }

      guard let unitName = object ["@name"] as? String else
      {
         return console .warn (t("Expected unit name identificator."))
      }
      
      guard let conversionFactor = object ["@conversionFactor"] as? Double else
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

      guard let metaName = object ["@name"] as? String else
      {
         return console .warn (t("Expected metadata key."))
      }
      
      guard let metaContent = object ["@content"] as? String else
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
   }

   private final func protoDeclareObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
   }

   private final func routeObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
   }

   private final func importObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
   }

   private final func exportObject (_ object : Any?)
   {
      guard let object = object as? [String : Any] else { return }
   }

   private final func nodeObject (_ object : Any?, nodeType : String) -> X3DNode?
   {
      guard let object = object as? [String : Any] else { return nil }
      
      // USE property

      do
      {
         if let nodeName = object ["@USE"] as? String
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
            guard let name = object ["@name"] as? String else
            {
               console .warn (t("Couldn't create proto instance, no name given."))
               return nil
            }
            
            prototypeInstance = true
            node              = try executionContext .createProto (typeName: name)
         }
         else
         {
            node = try executionContext .createNode (typeName: nodeType)
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
         if let nodeName = object ["@DEF"] as? String
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
            fieldValueValue (object ["-metadata"], metadata)
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

   private final func fieldArray (_ object : Any?, _ node : X3DNode)
   {
      guard let object = object as? [Any] else { return }
   }

   private final func fieldValueArray (_ object : Any?, _ node : X3DNode)
   {
      guard let object = object as? [Any] else { return }
   }

   private final func sourceTextArray (_ object : Any?, _ node : X3DNode)
   {
      guard let object = object as? [Any] else { return }
   }
   
   private final func isObject (_ object : Any?, _ node : X3DNode)
   {
      guard let object = object as? [String : Any] else { return }
   }

   private final func fieldValueValue (_ object : Any?, _ field : X3DField) -> Bool
   {
      if (fieldValue (object, field))
      {
         field .isSet = true
         return true
      }

      return false
   }

   private final func fieldValue (_ object : Any?, _ field : X3DField) -> Bool
   {
      switch field .getType ()
      {
         case .SFBool:   return sfboolValue   (object, field as! SFBool)
         case .SFDouble: return sfdoubleValue (object, field as! SFDouble)
         case .SFFloat:  return sffloatValue  (object, field as! SFFloat)
         case .SFInt32:  return sfint32Value  (object, field as! SFInt32)
         case .SFString: return sfstringValue (object, field as! SFString)
         case .SFTime:   return sftimeValue   (object, field as! SFTime)

         case .MFBool:   return mfboolValue   (object, field as! MFBool)
         case .MFDouble: return mfdoubleValue (object, field as! MFDouble)
         case .MFFloat:  return mffloatValue  (object, field as! MFFloat)
         case .MFInt32:  return mfint32Value  (object, field as! MFInt32)
         case .MFString: return mfstringValue (object, field as! MFString)
         case .MFTime:   return mftimeValue   (object, field as! MFTime)
         
         default: return false
      }
   }
   
   private final func sfboolValue (_ object : Any?, _ field : SFBool) -> Bool
   {
      guard let object = object as? Bool else { return false }
      
      field .wrappedValue = object
      
      return true
   }
   
   private final func mfboolValue (_ objects : Any?, _ field : MFBool) -> Bool
   {
      guard let objects = objects as? [Bool] else { return false }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: objects)
      
      return true
   }
   
   private final func sfdoubleValue (_ object : Any?, _ field : SFDouble) -> Bool
   {
      guard let object = object as? Double else { return false }
      
      field .wrappedValue = object
      
      return true
   }
   
   private final func mfdoubleValue (_ objects : Any?, _ field : MFDouble) -> Bool
   {
      guard let objects = objects as? [Double] else { return false }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: objects)
      
      return true
   }
   
   private final func sffloatValue (_ object : Any?, _ field : SFFloat) -> Bool
   {
      guard let object = object as? Float else { return false }
      
      field .wrappedValue = object
      
      return true
   }
   
   private final func mffloatValue (_ objects : Any?, _ field : MFFloat) -> Bool
   {
      guard let objects = objects as? [Float] else { return false }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: objects)
      
      return true
   }
   
   private final func sfint32Value (_ object : Any?, _ field : SFInt32) -> Bool
   {
      guard let object = object as? Int32 else { return false }
      
      field .wrappedValue = object
      
      return true
   }
   
   private final func mfint32Value (_ objects : Any?, _ field : MFInt32) -> Bool
   {
      guard let objects = objects as? [Int32] else { return false }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: objects)
      
      return true
   }
   
   private final func sfstringValue (_ object : Any?, _ field : SFString) -> Bool
   {
      guard let object = object as? String else { return false }
      
      field .wrappedValue = object
      
      return true
   }
   
   private final func mfstringValue (_ objects : Any?, _ field : MFString) -> Bool
   {
      guard let objects = objects as? [String] else { return false }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: objects)
      
      return true
   }
   
   private final func sftimeValue (_ object : Any?, _ field : SFTime) -> Bool
   {
      guard let object = object as? Double else { return false }
      
      field .wrappedValue = object
      
      return true
   }
   
   private final func mftimeValue (_ objects : Any?, _ field : MFTime) -> Bool
   {
      guard let objects = objects as? [Double] else { return false }
      
      field .wrappedValue .removeAll ()
      field .wrappedValue .append (contentsOf: objects)
      
      return true
   }
}
