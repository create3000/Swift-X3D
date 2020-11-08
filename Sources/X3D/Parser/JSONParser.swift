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
         throw X3DError .INVALID_X3D ("Couldn't read JSON data.")
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
      
      debugPrint (#function)
   }
   
   private final func sceneObject (_ element : Any?)
   {
      guard let element = element as? [String : Any] else { return }
      
      debugPrint (#function)
   }
}
