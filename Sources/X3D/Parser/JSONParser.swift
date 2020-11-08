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
      
      var components = X3DComponentInfoArray ()

      for element in element
      {
         if let componentStatement = componentObject (element)
         {
            components .append (componentStatement)
         }
      }
      
      scene .components = components
   }
   
   private final func componentObject (_ element : Any?) -> X3DComponentInfo?
   {
      guard let element = element as? [String : Any] else { return nil }
      
      guard let componentName = element ["@name"] as? String else
      {
         scene .browser! .console .warn (t("Expected a component name."))
         return nil
      }
      
      guard let componentLevel = element ["@level"] as? Int32 else
      {
         scene .browser! .console .warn (t("Expected a component support level."))
         return nil
      }
      
      do
      {
         return try scene .browser! .getComponent (name: componentName, level: componentLevel)
      }
      catch
      {
         scene .browser! .console .warn (error .localizedDescription)
         return nil
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
         scene .browser! .console .warn (t("Expected category name identificator in unit statement."))
         return
      }
      
      guard let category = X3DUnitCategory (categoryName) else
      {
         scene .browser! .console .warn (t("Unkown unit category '%@'.", categoryName))
         return
      }

      guard let unitName = element ["@name"] as? String else
      {
         scene .browser! .console .warn (t("Expected unit name identificator."))
         return
      }
      
      guard let conversionFactor = element ["@conversionFactor"] as? Double else
      {
         scene .browser! .console .warn (t("Expected unit conversion factor."))
         return
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
         scene .browser! .console .warn (t("Expected metadata key."))
         return
      }
      
      guard let metaContent = element ["@content"] as? String else
      {
         scene .browser! .console .warn (t("Expected metadata value."))
         return
      }
      
      scene .metadata [metaName, default: [ ]] .append (metaContent)
   }

   private final func sceneObject (_ element : Any?)
   {
      guard let element = element as? [String : Any] else { return }
      
      debugPrint (#function)
   }
}
