//
//  X3DBrowser.swift
//  X3D
//
//  Created by Holger Seelig on 06.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation
import Gzip

public final class X3DBrowser :
   X3DBrowserContext
{
   // Properties
   
   public final override var browser : X3DBrowser { self }
   
   // Initialization
   
   public override func initialize ()
   {
      super .initialize ()
      
      replaceWorld (scene: nil)
   
      console .info (t("Welcome to %@ v%@", name, version))
      console .info (t("\tCurrent Graphics Renderer"))
      console .info (t("\t\tName: %@", device! .name))
   }
   
   // Configuration
   
   public final func getProfile (name : String) throws -> X3DProfileInfo
   {
      guard let profile = supportedProfiles [name] else
      {
         throw X3DError .INVALID_NAME (t("Profile named '%@' does not exists.", name))
      }
      
      return profile
   }
   
   public final func getComponent (name : String, level : Int32) throws -> X3DComponentInfo
   {
      guard let component = supportedComponents [name] else
      {
         throw X3DError .INVALID_NAME (t("Component named '%@' does not exists.", name))
      }
      
      guard level <= component .level else
      {
         throw X3DError .NOT_SUPPORTED (t("Component level '%d' for component '%@' is not supported.", level, name))
      }
      
      return component
   }

   // Scene handling
   
   public final func createScene (profile : X3DProfileInfo, components : X3DComponentInfoArray) -> X3DScene
   {
      let scene = X3DScene (with: self)
      
      scene .profile    = profile
      scene .components = components
      
      scene .setup ()
      
      return scene
   }
   
   public final func replaceWorld (scene : X3DScene?)
   {
      // Send message.
      
      if scene != nil
      {
         console .info (t("The browser is requested to replace the world with '%@'.", scene! .worldURL .description))
      }
      
      // Shutdown world.
      
      if world != nil
      {
         callBrowserInterests (event: .Browser_Shutdown)
         
         currentScene .endUpdate ()
      }
      
      // Initialize world.

      currentScene = scene ?? createScene (profile: try! getProfile (name: "Full"), components: [ ])
      world        = X3DWorld (with: currentScene)
      
      if live
      {
         currentScene .beginUpdate ()
      }
      
      callBrowserInterests (event: .Browser_Initialized)
      
      setNeedsDisplay ()
   }
   
   public final func loadURL (url : [URL], parameter : [String])
   {
      browserQueue .async
      {
         for URL in url
         {
            do
            {
               let data      = try Data (contentsOf: URL)
               let x3dSyntax = String (decoding: data .isGzipped ? try data .gunzipped () : data, as: UTF8 .self)
               let scene     = X3DScene (with: self)

               scene .worldURL = URL .absoluteURL
               
               try X3DGoldenGate .parseIntoScene (scene: scene, x3dSyntax: x3dSyntax)
               
               scene .setup ()
               
               DispatchQueue .main .async
               {
                  self .replaceWorld (scene: scene)
               }
               
               return
            }
            catch
            {
               self .console .warn (t("Couldn't load URL '%@'. %@", URL .absoluteURL .description, error .localizedDescription))
               continue
            }
         }
         
         self .console .error (t("Couldn't load any URL of '%@'.", url .map { $0 .absoluteURL .description } .joined (separator: "', '")))
      }
   }
   
   public final func createX3DFromString (x3dSyntax : String) throws -> X3DScene
   {
      let scene = X3DScene (with: self)

      scene .worldURL = currentScene .worldURL
      
      try X3DGoldenGate .parseIntoScene (scene: scene, x3dSyntax: x3dSyntax)
      
      scene .setup ()
      
      return scene
   }
   
   /// Creates a new scene from `url`. This function is thread save.
   public final func createX3DFromURL (url : [URL]) throws -> X3DScene
   {
      for URL in url
      {
         do
         {
            let data      = try Data (contentsOf: URL)
            let x3dSyntax = String (decoding: data .isGzipped ? try data .gunzipped () : data, as: UTF8 .self)
            let scene     = X3DScene (with: self)

            scene .worldURL = URL .absoluteURL
            
            try X3DGoldenGate .parseIntoScene (scene: scene, x3dSyntax: x3dSyntax)
            
            scene .setup ()
            
            console .info (t("Done loading scene '%@'", scene .worldURL .description))
            
            return scene
         }
         catch
         {
            console .warn (t("Couldn't load URL '%@'. %@", URL .absoluteURL .description, error .localizedDescription))
            continue
         }
      }
      
      let errorDescription = t("Couldn't load any URL of '%@'.", url .map { $0 .absoluteURL .description } .joined (separator: "', '"))
      
      console .error (errorDescription)
      
      throw X3DError .INVALID_X3D (errorDescription)
   }

   // Update control
   
   public private(set) final var live : Bool = true

   public final func beginUpdate ()
   {
      live = true
      
      currentScene .beginUpdate ()
   }

   public final func endUpdate ()
   {
      live = false
      
      currentScene .endUpdate ()
   }
   
   // Browser interests
   
   private final var browserInterests : [X3DBrowserEvent : SFTime] = [
      .Browser_Initialized:      SFTime (),
      .Browser_Shutdown:         SFTime (),
      .Browser_URL_Error:        SFTime (),
      .Browser_Connection_Error: SFTime (),
      .Browser_Event:            SFTime (),
      .Browser_Sensors:          SFTime (),
      .Browser_Done:             SFTime (),
   ]

   public final func addBrowserInterest <Object : X3DInputOutput>
      (event : X3DBrowserEvent, method : @escaping (Object) -> (X3DRequester), object : Object)
   {
      browserInterests [event]! .addInterest (method, object)
   }

   public final func removeBrowserInterest <Object : X3DInputOutput>
      (event : X3DBrowserEvent, method : @escaping (Object) -> (X3DRequester), object : Object)
   {
      browserInterests [event]! .removeInterest (method, object)
   }
   
   internal final override func callBrowserInterests (event : X3DBrowserEvent)
   {
      browserInterests [event]! .processInterests ()
   }
   
   // Shared browser
   
   /// Set shared browser from which to observe events.
   public final weak var sharedBrowser : X3DBrowser? = nil
   {
      willSet
      {
         sharedBrowser? .removeBrowserInterest (event: .Browser_Event, method: X3DBrowser .setNeedsDisplay, object: self)
      }
      
      didSet
      {
         sharedBrowser? .addBrowserInterest (event: .Browser_Event, method: X3DBrowser .setNeedsDisplay, object: self)
      }
   }
   
   // Logging
   
   public final func print (_ arguments : CustomStringConvertible...)
   {
      console .log (arguments .map { $0 .description } .joined (separator: " "), lineBreak: false)
   }
   
   public final func println (_ arguments : CustomStringConvertible...)
   {
      console .log (arguments .map { $0 .description } .joined (separator: " "), lineBreak: true)
   }

   // Destruction
      
   deinit
   {
      debugPrint (#file, #function)
      
      sharedBrowser? .removeBrowserInterest (event: .Browser_Event, method: X3DBrowser .setNeedsDisplay, object: self)
   }
}

