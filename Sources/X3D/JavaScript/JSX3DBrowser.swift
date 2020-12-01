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
   typealias SFNode = JavaScript .SFNode
   
   var name             : String { get }
   var version          : String { get }
   var currentSpeed     : Double { get }
   var currentFrameRate : Double { get }
   var description      : String { get set }
   
   func getRenderingProperty (_ name : String) -> Any?
   func getBrowserProperty (_ name : String) -> Any?
   func getBrowserOption (_ name : String) -> Any?
   func setBrowserOption (_ name : String, _ value : Any)
   
   func print ()
   func println ()

   func getName () -> String
   func getVersion () -> String
   func getCurrentSpeed () -> Double
   func getCurrentFrameRate () -> Double
   func getWorldURL () -> String
   
   func createVrmlFromString (_ vrmlSyntax : String) -> Any?
   func createVrmlFromURL (_ url : [String], _ node : SFNode?, _ event : String)
   
   func addRoute (_ sourceNode : SFNode?,
                  _ sourceField : String,
                  _ destinationNode : SFNode?,
                  _ destinationField : String)
   func deleteRoute (_ sourceNode : SFNode?,
                     _ sourceField : String,
                     _ destinationNode : SFNode?,
                     _ destinationField : String)


   func toString () -> String
}

extension JavaScript
{
   @objc internal final class X3DBrowser :
      NSObject,
      X3DBrowserFieldExports
   {
      // Properties
      
      internal unowned let browser          : X3D .X3DBrowser
      internal unowned let executionContext : X3D .X3DExecutionContext

      internal let cache = NSMapTable <X3D .X3DNode, JSValue> (keyOptions: .weakMemory, valueOptions: .strongMemory)
      
      // Construction
      
      internal static func register (_ context : JSContext, _ browser : X3DBrowser)
      {
         context ["X3DBrowser"] = Self .self
         context ["Browser"]    = browser
         
         context .evaluateScript ("""
(function (targets)
{
   const createVrmlFromURL = X3DBrowser .prototype .createVrmlFromURL;
   const addRoute          = X3DBrowser .prototype .addRoute;
   const deleteRoute       = X3DBrowser .prototype .deleteRoute;

   X3DBrowser .prototype .setDescription = function (newValue) { this .description = newValue; };
   
   X3DBrowser .prototype .createVrmlFromURL = function (url, node, event)
   {
      return createVrmlFromURL .call (this, url, targets .get (node), event)
   };
   
   X3DBrowser .prototype .addRoute = function (sourceNode, sourceField, destinationNode, destinationField)
   {
      return addRoute .call (this, targets .get (sourceNode), sourceField, targets .get (destinationNode), destinationField)
   };

   X3DBrowser .prototype .deleteRoute = function (sourceNode, sourceField, destinationNode, destinationField)
   {
      return deleteRoute .call (this, targets .get (sourceNode), sourceField, targets .get (destinationNode), destinationField)
   };
})
(targets)
""")
      }

      internal init (_ browser : X3D .X3DBrowser, _ executionContext : X3D .X3DExecutionContext)
      {
         self .browser          = browser
         self .executionContext = executionContext
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

      // print
      
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
      
      func getRenderingProperty (_ name : String) -> Any?
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
      
      func getBrowserProperty (_ name : String) -> Any?
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
      
      func getBrowserOption (_ name : String) -> Any?
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
      
      func setBrowserOption (_ name : String, _ value : Any)
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

      // VRML
      
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
         return executionContext .getWorldURL () .absoluteURL .description
      }
      
      public final func createVrmlFromString (_ vrmlSyntax : String) -> Any?
      {
         do
         {
            let scene = try browser .createX3DFromString (x3dSyntax: vrmlSyntax)
            
            return JavaScript .getValue (JSContext .current (), self, scene .$rootNodes)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func createVrmlFromURL (_ url : [String], _ node : SFNode?, _ event : String)
      {
         guard let node = node else { return }
         
         guard let field = try? node .field .wrappedValue .getField (name: event) else
         {
            return exception (t("No such event or field '%@' in node class %@.", event, node .field .wrappedValue .getTypeName ()))
         }
         
         guard field .getType () == .MFNode else
         {
            return exception (t("Field '%@' in node %@ must be of type MFNode.", event, node .field .wrappedValue .getTypeName ()))
         }

         browser .browserQueue .async
         {
            do
            {
               let scene = try self .browser .createX3DFromURL (url: url .map
               {
                  URL (string: $0, relativeTo: self .executionContext .getWorldURL ())
               }
               .compactMap { $0 })
               
               DispatchQueue .main .async { field .set (value: scene .$rootNodes) }
            }
            catch
            {
               self .browser .console .error (error .localizedDescription)
            }
         }
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
