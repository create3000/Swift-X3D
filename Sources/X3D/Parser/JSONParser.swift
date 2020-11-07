//
//  File.swift
//  
//
//  Created by Holger Seelig on 07.11.20.
//

internal final class JSONParser :
   X3DParser
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
   
   internal final var isJSON : Bool
   {
      return json != nil
   }

   internal final func parseIntoScene () throws
   {
      guard let json = json else
      {
         throw X3DError .INVALID_X3D ("Couldn't read JSON data.")
      }

      x3d (json ["X3D"] as? [String : Any])
   }
   
   // Parse
   
   private final func x3d (_ element : [String : Any]?)
   {
      guard let element = element else { return }
      
      debugPrint ("JSON")
   }
}
