//
//  File.swift
//  
//
//  Created by Holger Seelig on 04.12.20.
//

import JavaScriptCore

@objc internal protocol X3DSceneExports :
   JSExport
{
   typealias SFNode = JavaScript .SFNode
   typealias MFNode = JavaScript .MFNode

   var rootNodes : JSValue { get set }
   
   func getMetaData (_ key : String) -> String?
   func addMetaData (_ key : String, _ value : String)
   func setMetaData (_ key : String, _ value : String)
   func removeMetaData (_ key : String)

   func getExportedNode (_ exportedName : String) -> JSValue?
   func addExportedNode (_ exportedName : String, _ node : SFNode?)
   func updateExportedNode (_ exportedName : String, _ node : SFNode?)
   func removeExportedNode (_ exportedName : String)

   func toString () -> String
}

extension JavaScript
{
   @objc internal final class X3DScene :
      X3DExecutionContext,
      X3DSceneExports
   {
      // Construction
      
      public final override class func register (_ context : JSContext)
      {
         context ["X3DScene"] = Self .self
         
         context .evaluateScript ("""
(function (targets)
{
   const addExportedNode    = X3DScene .prototype .addExportedNode;
   const updateExportedNode = X3DScene .prototype .updateExportedNode;

   X3DScene .prototype .addExportedNode = function (exportedName, node)
   {
      return addExportedNode .call (this, exportedName, targets .get (node));
   };

   X3DScene .prototype .updateExportedNode = function (exportedName, node)
   {
      return updateExportedNode .call (this, exportedName, targets .get (node));
   };
})
(targets);

DefineProperty (this, \"X3DScene\", X3DScene);
""")
      }
      
      internal let scene : X3D .X3DScene
      
      internal init (_ scene : X3D .X3DScene)
      {
         self .scene = scene
         
         super .init (scene)
      }
      
      // Property access
      
      dynamic public override final var rootNodes : JSValue
      {
         get
         {
            MFNode .initWithProxy (JSContext .current (), field: executionContext .$rootNodes)!
         }
         set
         {
            guard let target = JSContext .current ()? .target (newValue)? .toObjectOf (MFNode .self) as? MFNode else
            {
               return exception ("Couldn't assign value to property rootNodes, must be a MFNode.")
            }
            
            executionContext .rootNodes = target .field .wrappedValue
         }
      }
      
      // Metadata handling
      
      public final func getMetaData (_ key : String) -> String?
      {
         return scene .getMetaData (key: key)? .last
      }
      
      public final func addMetaData (_ key : String, _ value : String)
      {
         scene .addMetaData (key: key, value: value)
      }
      
      public final func setMetaData (_ key : String, _ value : String)
      {
         scene .setMetaData (key: key, value: value)
      }
      
      public final func removeMetaData (_ key : String)
      {
         scene .removeMetaData (key: key)
      }
 
      // Exported node handling
      
      public final func getExportedNode (_ exportedName : String) -> JSValue?
      {
         do
         {
            return SFNode .initWithProxy (JSContext .current (), field: X3D .SFNode (wrappedValue: try scene .getExportedNode (exportedName: exportedName)))
         }
         catch
         {
            return exception (error .localizedDescription)
         }
     }
      
      public final func addExportedNode (_ exportedName : String, _ node : SFNode?)
      {
         do
         {
            guard let node = node? .field .wrappedValue else
            {
               return exception ("Node must be a SFNode not NULL.")
            }
            
            try scene .addExportedNode (exportedName: exportedName, node: node)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }
      
      public final func updateExportedNode (_ exportedName : String, _ node : SFNode?)
      {
         do
         {
            guard let node = node? .field .wrappedValue else
            {
               return exception ("Node must be a SFNode not NULL.")
            }
            
            try scene .updateExportedNode (exportedName: exportedName, node: node)
         }
         catch
         {
            return exception (error .localizedDescription)
         }
      }

      public final func removeExportedNode (_ exportedName : String)
      {
         scene .removeExportedNode (exportedName: exportedName)
      }

      // Input/Output
      
      public final override func toString () -> String
      {
         return "[object X3DScene]"
      }
   }
}
