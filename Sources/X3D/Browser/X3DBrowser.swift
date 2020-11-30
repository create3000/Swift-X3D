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
   
      console .info (t("Welcome to %@ v%@", getName (), getVersion ()))
      console .info (t("\tCurrent Graphics Renderer"))
      console .info (t("\t\tName: %@", device! .name))
      console .info ()
   }
   
   // Configuration
   
   public final func getName () -> String { "Sunrise X3D Browser" }
   
   public final func getVersion () -> String { "1.0" }
   
   public final func getCurrentSpeed () -> Double { currentSpeed }
   
   public final func getCurrentFrameRate () -> Double { currentFrameRate }
   
   public final func getSupportedProfiles () -> [X3DProfileInfo]
   {
      var profiles = [X3DProfileInfo] ()
      
      for (_, profile) in SupportedProfiles .profiles
      {
         profiles .append (profile)
      }
      
      return profiles .sorted { $0 .name < $1 .name }
   }

   public final func getProfile (name : String) throws -> X3DProfileInfo
   {
      guard let profile = SupportedProfiles .profiles [name] else
      {
         throw X3DError .INVALID_NAME (t("Profile named '%@' does not exists.", name))
      }
      
      return profile
   }
   
   public final func getSupportedComponents () -> [X3DComponentInfo]
   {
      var components = [X3DComponentInfo] ()
      
      for (_, component) in SupportedComponents .components
      {
         components .append (component)
      }
      
      return components .sorted { $0 .name < $1 .name }
   }
   
   public final func getComponent (name : String, level : Int32) throws -> X3DComponentInfo
   {
      guard let component = SupportedComponents .components [SupportedComponents .aliases [name] ?? name] else
      {
         throw X3DError .INVALID_NAME (t("Component named '%@' does not exists.", name))
      }
      
      guard level <= component .level else
      {
         throw X3DError .NOT_SUPPORTED (t("Component level '%d' for component '%@' is not supported.", level, name))
      }
      
      return component
   }
   
   public final func getSupportedNodes () -> [String]
   {
      var nodes = [String] ()
      
      for (name, _) in SupportedNodes .nodes
      {
         nodes .append (name)
      }
      
      return nodes .sorted ()
   }
   
   public final func getSupportedFields () -> [String]
   {
      var fields = [String] ()
      
      for (name, _) in SupportedFields .fields
      {
         fields .append (name)
      }
      
      return fields .sorted ()
   }

   // Scene handling
   
   public final func getExecutionContext () -> X3DScene { currentScene }
   
   public final func createScene (profile : X3DProfileInfo, components : [X3DComponentInfo]) -> X3DScene
   {
      let scene = X3DScene (with: self)
      
      scene .setProfile (profile)
      scene .setComponents (components)
      scene .setup ()
      
      return scene
   }
   
   public final func replaceWorld (scene : X3DScene?)
   {
      // Send message.
      
      if scene != nil
      {
         console .info (t("The browser is requested to replace the world with '%@'.", scene! .getWorldURL () .description))
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

               scene .setWorldURL (URL .absoluteURL)
               
               try GoldenGate .parseIntoScene (scene: scene, x3dSyntax: x3dSyntax)
               
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
   
   private final var browserDescription : String = ""
   
   public final func getDescription () -> String
   {
      return browserDescription
   }
   
   public final func setDescription (_ string : String)
   {
      browserDescription = string
   }
   
   public final func createX3DFromString (x3dSyntax : String) throws -> X3DScene
   {
      let scene = X3DScene (with: self)

      scene .setWorldURL (currentScene .getWorldURL ())
      
      try GoldenGate .parseIntoScene (scene: scene, x3dSyntax: x3dSyntax)
      
      scene .setup ()
      
      return scene
   }
   
   public final func createX3DFromStream (stream : InputStream) throws -> X3DScene
   {
      let data      = Data (reading: stream)
      let x3dSyntax = String (decoding: data .isGzipped ? try data .gunzipped () : data, as: UTF8 .self)
      
      return try createX3DFromString (x3dSyntax: x3dSyntax)
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

            scene .setWorldURL (URL .absoluteURL)
            
            try GoldenGate .parseIntoScene (scene: scene, x3dSyntax: x3dSyntax)
            
            scene .setup ()
            
            console .info (t("Done loading scene '%@'", scene .getWorldURL () .description))
            
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
   
   private final var live : Bool = true

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
   
   // Browser properties
   
   public final func getRenderingProperties () -> RenderingProperties { renderingProperties }
   
   public final func getBrowserProperties () -> BrowserProperties { browserProperties }
   
   public final func getBrowserOptions () -> BrowserOptions { browserOptions }

   // Viewpoint handling
   
   // nextViewpoint
   // previousViewpoint
   // firstViewpoint
   // lastViewpoint
   
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
      (event : X3DBrowserEvent, id: String, method : @escaping (Object) -> (X3DRequester), object : Object)
   {
      browserInterests [event]! .addInterest (id, method, object)
   }

   public final func removeBrowserInterest <Object : X3DInputOutput>
      (event : X3DBrowserEvent, id: String, method : @escaping (Object) -> (X3DRequester), object : Object)
   {
      browserInterests [event]! .removeInterest (id, method, object)
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
         sharedBrowser? .removeBrowserInterest (event: .Browser_Event, id: "setNeedsDisplay", method: X3DBrowser .setNeedsDisplay, object: self)
      }
      
      didSet
      {
         sharedBrowser? .addBrowserInterest (event: .Browser_Event, id: "setNeedsDisplay", method: X3DBrowser .setNeedsDisplay, object: self)
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
   
   public final func getConsole () -> X3DConsole { console }

   // Destruction
      
   deinit
   {
      debugPrint (#file, #function)
      
      sharedBrowser? .removeBrowserInterest (event: .Browser_Event, id: "setNeedsDisplay", method: X3DBrowser .setNeedsDisplay, object: self)
   }
}

fileprivate extension Data
{
   init (reading stream : InputStream)
   {
      self .init ()
      
      stream .open ()

      let bufferSize = 1024
      let buffer     = UnsafeMutablePointer <UInt8> .allocate (capacity: bufferSize)
      
      defer { buffer .deallocate () }

      while stream .hasBytesAvailable
      {
         let read = stream .read (buffer, maxLength: bufferSize)
         
         if (read == 0)
         {
            break // added
         }
         
         self .append (buffer, count: read)
      }

      stream .close ()
   }
}
