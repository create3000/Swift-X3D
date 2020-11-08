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
   
   private final func x3dObject (_ element : Any?)
   {
      guard let element = element as? [String : Any] else { return }
      
      executionContexts .append (scene)
      
      defer { executionContexts .removeLast () }
      
      if let _ = element ["encoding"] as? String
      {
         
      }
      
      if let profileString = element ["@profile"] as? String
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
      
      if let versionString = element ["@version"] as? String
      {
         scene .specificationVersion = versionString
      }

      headObject (element ["head"])

      sceneObject (element ["Scene"])
   }
   
   private final func headObject (_ element : Any?)
   {
      guard let element = element as? [String : Any] else { return }
      
      componentArray (element ["component"])
      unitArray      (element ["unit"])
      metaArray      (element ["meta"])
   }
   
   private final func componentArray (_ element : Any?)
   {
      guard let element = element as? [Any] else { return }

      for element in element
      {
         componentObject (element)
      }
   }
   
   private final func componentObject (_ element : Any?)
   {
      guard let element = element as? [String : Any] else { return }
      
      guard let componentName = element ["@name"] as? String else
      {
         return scene .browser! .console .warn (t("Expected a component name."))
      }
      
      guard let componentLevel = element ["@level"] as? Int32 else
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
   
   private final func unitArray (_ element : Any?)
   {
      guard let element = element as? [Any] else { return }
      
      for element in element
      {
         unitObject (element)
      }
   }
   
   private final func unitObject (_ element : Any?)
   {
      guard let element = element as? [String : Any] else { return }
      
      guard let categoryName = element ["@category"] as? String else
      {
         return scene .browser! .console .warn (t("Expected category name identificator in unit statement."))
      }
      
      guard let category = X3DUnitCategory (categoryName) else
      {
         return scene .browser! .console .warn (t("Unkown unit category '%@'.", categoryName))
      }

      guard let unitName = element ["@name"] as? String else
      {
         return scene .browser! .console .warn (t("Expected unit name identificator."))
      }
      
      guard let conversionFactor = element ["@conversionFactor"] as? Double else
      {
         return scene .browser! .console .warn (t("Expected unit conversion factor."))
      }
      
      scene .updateUnit (category, name: unitName, conversionFactor: conversionFactor)
   }

   private final func metaArray (_ element : Any?)
   {
      guard let element = element as? [Any] else { return }
      
      for element in element
      {
         metaObject (element)
      }
   }

   private final func metaObject (_ element : Any?)
   {
      guard let element = element as? [String : Any] else { return }

      guard let metaName = element ["@name"] as? String else
      {
         return scene .browser! .console .warn (t("Expected metadata key."))
      }
      
      guard let metaContent = element ["@content"] as? String else
      {
         return scene .browser! .console .warn (t("Expected metadata value."))
      }
      
      scene .metadata [metaName, default: [ ]] .append (metaContent)
   }

   private final func sceneObject (_ element : Any?)
   {
      guard let element = element as? [String : Any] else { return }
      
      debugPrint (#function)
   }
}
