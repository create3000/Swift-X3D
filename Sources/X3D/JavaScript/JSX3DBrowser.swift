//
//  File.swift
//  
//
//  Created by Holger Seelig on 30.11.20.
//

import JavaScriptCore

@objc internal protocol X3DBrowserFieldExports :
   JSExport
{
   typealias SFNode   = JavaScript .SFNode
   typealias MFString = JavaScript .MFString
   typealias X3DScene = JavaScript .X3DScene
   
   // X3D
   
   var name             : String { get }
   var version          : String { get }
   var currentSpeed     : Double { get }
   var currentFrameRate : Double { get }
   var description      : String { get set }
   
   var currentScene : Any { get }
   
   func replaceWorld (_ scene : JSValue?)
   func createX3DFromString (_ x3dSyntax : String) -> X3DScene?
   func createX3DFromURL (_ url : MFString?, _ node : SFNode?, _ event : String?) -> Any?
   func loadURL (_ url : MFString?, _ parameter : MFString?)

   func getRenderingProperty (_ name : String) -> Any?
   func getBrowserProperty (_ name : String) -> Any?
   func getBrowserOption (_ name : String) -> Any?
   func setBrowserOption (_ name : String, _ value : Any?)
   
   func firstViewpoint (_ layer : SFNode?)
   func previousViewpoint (_ layer : SFNode?)
   func nextViewpoint (_ layer : SFNode?)
   func lastViewpoint (_ layer : SFNode?)
   
   func print ()
   func println ()
   
   // VRML legacy

   func getName () -> String
   func getVersion () -> String
   func getCurrentSpeed () -> Double
   func getCurrentFrameRate () -> Double
   func getWorldURL () -> String
   
   func createVrmlFromString (_ vrmlSyntax : String) -> Any?
   func createVrmlFromURL (_ url : MFString?, _ node : SFNode?, _ event : String)
   
   func addRoute (_ sourceNode : SFNode?,
                  _ sourceField : String,
                  _ destinationNode : SFNode?,
                  _ destinationField : String)
   func deleteRoute (_ sourceNode : SFNode?,
                     _ sourceField : String,
                     _ destinationNode : SFNode?,
                     _ destinationField : String)
   
   // Input/Output
   
   func toString () -> String
}

extension JavaScript
{
   @objc internal final class X3DBrowser :
      NSObject,
      X3DBrowserFieldExports
   {
      // Properties
      
      internal unowned final let browser          : X3D .X3DBrowser
      internal unowned final let executionContext : X3D .X3DExecutionContext
      internal final var targets                  : JSValue
      
      // Construction
      
      internal static func register (_ context : JSContext, _ browser : X3DBrowser)
      {
         context ["X3DBrowser"] = Self .self
         context ["Browser"]    = browser

         context .evaluateScript ("""
(function (global, Browser, targets)
{
   // X3D

   const replaceWorld      = X3DBrowser .prototype .replaceWorld;
   const createX3DFromURL  = X3DBrowser .prototype .createX3DFromURL;
   const loadURL           = X3DBrowser .prototype .loadURL;
   const firstViewpoint    = X3DBrowser .prototype .firstViewpoint;
   const previousViewpoint = X3DBrowser .prototype .previousViewpoint;
   const nextViewpoint     = X3DBrowser .prototype .nextViewpoint;
   const lastViewpoint     = X3DBrowser .prototype .lastViewpoint;

   X3DBrowser .prototype .replaceWorld = function (scene)
   {
      return replaceWorld .call (this, targets .get (scene) || scene);
   };

   X3DBrowser .prototype .loadURL = function (url, parameter)
   {
      return loadURL .call (this, targets .get (url), targets .get (parameter));
   };
   
   X3DBrowser .prototype .createX3DFromURL = function (url, node, event)
   {
      return createX3DFromURL .call (this, targets .get (url), targets .get (node), event);
   };
   
   X3DBrowser .prototype .firstViewpoint = function (layer)
   {
      return firstViewpoint .call (this, targets .get (layer));
   };
   
   X3DBrowser .prototype .previousViewpoint = function (layer)
   {
      return previousViewpoint .call (this, targets .get (layer));
   };
   
   X3DBrowser .prototype .nextViewpoint = function (layer)
   {
      return nextViewpoint .call (this, targets .get (layer));
   };
   
   X3DBrowser .prototype .lastViewpoint = function (layer)
   {
      return lastViewpoint .call (this, targets .get (layer));
   };

   // Wrap VRML legacy functions.
   
   const createVrmlFromURL = X3DBrowser .prototype .createVrmlFromURL;
   const addRoute          = X3DBrowser .prototype .addRoute;
   const deleteRoute       = X3DBrowser .prototype .deleteRoute;

   X3DBrowser .prototype .setDescription = function (newValue) { this .description = newValue; };
   
   X3DBrowser .prototype .createVrmlFromURL = function (url, node, event)
   {
      return createVrmlFromURL .call (this, targets .get (url), targets .get (node), event);
   };
   
   X3DBrowser .prototype .addRoute = function (sourceNode, sourceField, destinationNode, destinationField)
   {
      return addRoute .call (this, targets .get (sourceNode), sourceField, targets .get (destinationNode), destinationField);
   };

   X3DBrowser .prototype .deleteRoute = function (sourceNode, sourceField, destinationNode, destinationField)
   {
      return deleteRoute .call (this, targets .get (sourceNode), sourceField, targets .get (destinationNode), destinationField);
   };

   // Define properties.

   DefineProperty (global, "X3DBrowser", X3DBrowser);
   DefineProperty (global, "Browser",    Browser);
})
(this, Browser, targets);
""")
      }

      internal init (_ context : JSContext, _ browser : X3D .X3DBrowser, _ executionContext : X3D .X3DExecutionContext)
      {
         self .browser          = browser
         self .executionContext = executionContext
         self .targets          = context .evaluateScript ("(function (object) { return this .get (object) }) .bind (targets)")!
      }
      
      // Properties
      
      dynamic public final var name             : String { browser .getName () }
      dynamic public final var version          : String { browser .getVersion () }
      dynamic public final var currentSpeed     : Double { browser .getCurrentSpeed () }
      dynamic public final var currentFrameRate : Double { browser .getCurrentFrameRate () }
      
      dynamic public final override var description : String
      {
         get { browser .getDescription () }
         set { browser .setDescription (newValue) }
      }
      
      // Scene handling
      
      dynamic public final var currentScene : Any
      {
         if let scene = executionContext as? X3D .X3DScene
         {
            return X3DScene (scene)
         }
         else
         {
            return X3DExecutionContext (executionContext)
         }
      }
      
      public final func replaceWorld (_ scene : JSValue?)
      {
         if let scene = scene? .toObjectOf (X3DScene .self) as? X3DScene
         {
            browser .replaceWorld (scene: scene .scene)
         }
         else if let rootNodes = scene? .toObjectOf (MFNode .self) as? MFNode
         {
            // VRML version of replaceWorld has a MFNode value as argument.
            
            let scene = browser .createScene (profile: try! browser .getProfile (name: "Full"), components: [ ])
            
            for rootNode in rootNodes .field .wrappedValue
            {
               guard let rootNode = rootNode else { continue }
               
               scene .$isLive .addFieldInterest (to: rootNode .scene! .$isLive)
               
               browser .scriptingScenes .append (rootNode .scene!)
            }
            
            scene .rootNodes = rootNodes .field .wrappedValue
            
            browser .replaceWorld (scene: scene)
         }
         else
         {
            browser .replaceWorld (scene: nil)
         }
      }
      
      public final func createX3DFromString (_ x3dSyntax : String) -> X3DScene?
      {
         do
         {
            let scene = try browser .createX3DFromString (x3dSyntax: x3dSyntax)
            
            // TODO: cache scene.
            
            //browser .getExecutionContext () .$isLive .addFieldInterest (to: scene .$isLive)
            
            browser .scriptingScenes .append (scene)
            
            return X3DScene (scene)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func createX3DFromURL (_ url : MFString?, _ node : SFNode?, _ event : String?) -> Any?
      {
         if let url   = url,
            let node  = node,
            let event = event
         {
            guard let field = try? node .field .wrappedValue .getField (name: event) else
            {
               return exception (t("No such event or field '%@' in node class %@.", event, node .field .wrappedValue .getTypeName ()))
            }
            
            guard field .getType () == .MFNode else
            {
               return exception (t("Field '%@' in node %@ must be of type MFNode.", event, node .field .wrappedValue .getTypeName ()))
            }
            
            let worldURL = executionContext .getWorldURL ()

            browser .browserQueue .async
            {
               do
               {
                  let scene = try self .browser .createX3DFromURL (url: url .field .wrappedValue .map
                  {
                     URL (string: $0, relativeTo: worldURL)
                  }
                  .compactMap { $0 })
                  
                  DispatchQueue .main .async
                  {
                     self .browser .scriptingScenes .append (scene)
                     
                     field .set (value: scene .$rootNodes)
                  }
               }
               catch
               {
                  self .browser .console .error (error .localizedDescription)
               }
            }
            
            return JSValue (nullIn: JSContext .current ())
         }
         
         if let url = url
         {
            do
            {
               let scene = try browser .createX3DFromURL (url: url .field .wrappedValue .map
               {
                  URL (string: $0, relativeTo: executionContext .getWorldURL ())
               }
               .compactMap { $0 })
               
               //browser .getExecutionContext () .$isLive .addFieldInterest (to: scene .$isLive)
               
               browser .scriptingScenes .append (scene)
               
               return X3DScene (scene)
            }
            catch
            {
               return exception (error .localizedDescription)
            }
         }
         
         return exception ("Invalid argument.")
      }
 
      public final func loadURL (_ url : MFString?, _ parameter : MFString?)
      {
         guard let url       = url,
               let parameter = parameter
         else { return exception ("Invalid argument.") }
         
         browser .loadURL (url: url .field .wrappedValue .map
         {
            URL (string: $0, relativeTo: executionContext .getWorldURL ())
         }
         .compactMap { $0 }, parameter: parameter .field .wrappedValue)
      }
      
      // Properties handling
      
      public final func getRenderingProperty (_ name : String) -> Any?
      {
         do
         {
            let field = try browser .getRenderingProperties () .getField (name: name)

            return JavaScript .getValue (JSContext .current (), self, field)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func getBrowserProperty (_ name : String) -> Any?
      {
         do
         {
            let field = try browser .getBrowserProperties () .getField (name: name)
            
            return JavaScript .getValue (JSContext .current (), self, field)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func getBrowserOption (_ name : String) -> Any?
      {
         do
         {
            let field = try browser .getBrowserOptions () .getField (name: name)
         
            return JavaScript .getValue (JSContext .current (), self, field)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func setBrowserOption (_ name : String, _ value : Any?)
      {
         do
         {
            let field = try browser .getBrowserOptions () .getField (name: name)
            
            JavaScript .setValue (field, value)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      // Viewpoint handling
      
      public final func firstViewpoint (_ layer : SFNode?)
      {
         if let layer = layer
         {
            guard let layerNode = layer .field .wrappedValue as? X3DLayerNode else
            {
               return exception ("Invalid argument.")
            }
            
            browser .firstViewpoint (layer: layerNode)
         }
         else
         {
            browser .firstViewpoint ()
         }
      }
      
      public final func previousViewpoint (_ layer : SFNode?)
      {
         if let layer = layer
         {
            guard let layerNode = layer .field .wrappedValue as? X3DLayerNode else
            {
               return exception ("Invalid argument.")
            }
            
            browser .previousViewpoint (layer: layerNode)
         }
         else
         {
            browser .previousViewpoint ()
         }
      }
      
      public final func nextViewpoint (_ layer : SFNode?)
      {
         if let layer = layer
         {
            guard let layerNode = layer .field .wrappedValue as? X3DLayerNode else
            {
               return exception ("Invalid argument.")
            }
            
            browser .nextViewpoint (layer: layerNode)
         }
         else
         {
            browser .nextViewpoint ()
         }
      }
      
      public final func lastViewpoint (_ layer : SFNode?)
      {
         if let layer = layer
         {
            guard let layerNode = layer .field .wrappedValue as? X3DLayerNode else
            {
               return exception ("Invalid argument.")
            }
            
            browser .lastViewpoint (layer: layerNode)
         }
         else
         {
            browser .lastViewpoint ()
         }
      }

      // print handling
      
      public final func print ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            browser .print (args .map { $0 .toString () ?? "" } .joined (separator: " "))
         }
      }
      
      public final func println ()
      {
         if let args = JSContext .currentArguments () as? [JSValue]
         {
            browser .println (args .map { $0 .toString () ?? "" } .joined (separator: " "))
         }
      }

      // VRML legacy functions:
      
      public final func getName () -> String
      {
         return browser .getName ()
      }
      
      public final func getVersion () -> String
      {
         return browser .getVersion ()
      }
      
      public final func getCurrentSpeed () -> Double
      {
         return browser .getCurrentSpeed ()
      }
      
      public final func getCurrentFrameRate () -> Double
      {
         return browser .getCurrentFrameRate ()
      }
      
      public final func getWorldURL () -> String
      {
         return executionContext .getWorldURL () .absoluteString
      }
      
      public final func createVrmlFromString (_ vrmlSyntax : String) -> Any?
      {
         do
         {
            let scene = try browser .createX3DFromString (x3dSyntax: vrmlSyntax)
            
            browser .scriptingScenes .append (scene)
            
            return JavaScript .getValue (JSContext .current (), self, scene .$rootNodes)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func createVrmlFromURL (_ url : MFString?, _ node : SFNode?, _ event : String)
      {
         _ = createX3DFromURL (url, node, event)
      }
      
      public final func addRoute (_ sourceNode : SFNode?,
                                  _ sourceField : String,
                                  _ destinationNode : SFNode?,
                                  _ destinationField : String)
      {
         do
         {
            guard let sourceNode = sourceNode, let destinationNode = destinationNode else { return }
            
            try executionContext .addRoute (sourceNode: sourceNode .field .wrappedValue,
                                            sourceField: sourceField,
                                            destinationNode: destinationNode .field .wrappedValue,
                                            destinationField: destinationField)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func deleteRoute (_ sourceNode : SFNode?,
                                     _ sourceField : String,
                                     _ destinationNode : SFNode?,
                                     _ destinationField : String)
      {
         guard let sourceNode = sourceNode, let destinationNode = destinationNode else { return }
         
         executionContext .deleteRoute (sourceNode: sourceNode .field .wrappedValue,
                                        sourceField: sourceField,
                                        destinationNode: destinationNode .field .wrappedValue,
                                        destinationField: destinationField)
      }
      
      // Input/Output
      
      public final func toString () -> String
      {
         return "[object X3DBrowser]"
      }
   }
}
