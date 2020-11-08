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
            scene .browser! .console .warn (error .localizedDescription)
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
         return scene .browser! .console .warn (t("Expected a component name."))
      }
      
      guard let componentLevel = object ["@level"] as? Int32 else
      {
         return scene .browser! .console .warn (t("Expected a component support level."))
      }

      do
      {
         scene .components .append (try scene .browser! .getComponent (name: componentName, level: componentLevel))
      }
      catch
      {
         scene .browser! .console .warn (error .localizedDescription)
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
         return scene .browser! .console .warn (t("Expected category name identificator in unit statement."))
      }
      
      guard let category = X3DUnitCategory (categoryName) else
      {
         return scene .browser! .console .warn (t("Unkown unit category '%@'.", categoryName))
      }

      guard let unitName = object ["@name"] as? String else
      {
         return scene .browser! .console .warn (t("Expected unit name identificator."))
      }
      
      guard let conversionFactor = object ["@conversionFactor"] as? Double else
      {
         return scene .browser! .console .warn (t("Expected unit conversion factor."))
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
         return scene .browser! .console .warn (t("Expected metadata key."))
      }
      
      guard let metaContent = object ["@content"] as? String else
      {
         return scene .browser! .console .warn (t("Expected metadata value."))
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
               return nodeObject (value, nodeType: key)
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

   private final func nodeObject (_ object : Any?, nodeType : String) -> (Bool, X3DNode?)
   {
      guard let object = object as? [String : Any] else { return (false, nil) }
      
      return (false, nil)
   }
}
