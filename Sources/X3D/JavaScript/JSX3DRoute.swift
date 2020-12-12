//
//  File.swift
//  
//
//  Created by Holger Seelig on 12.12.20.
//

import JavaScriptCore

@objc internal protocol X3DRouteExports :
   JSExport
{
   var sourceNode       : JSValue { get }
   var sourceField      : String { get }
   var destinationNode  : JSValue { get }
   var destinationField : String { get }
   
   func toString () -> String
}

extension JavaScript
{
   @objc internal class X3DRoute :
      NSObject,
      X3DRouteExports
   {
      // Registration
      
      internal static func register (_ context : JSContext)
      {
         context ["X3DRoute"] = Self .self
         
         context .evaluateScript ("DefineProperty (this, \"X3DRoute\", X3DRoute);")
      }
      
      // Construction
      
      private final var route : X3D .X3DRoute
      
      internal init (_ route : X3D .X3DRoute)
      {
         self .route = route
      }
      
      // Property access
      
      dynamic public final var sourceNode : JSValue
      {
         SFNode .initWithProxy (JSContext .current (), field: X3D .SFNode (wrappedValue: route .sourceNode))
      }
      
      dynamic public final var sourceField : String { route .sourceField! .getName () }
      
      dynamic public final var destinationNode : JSValue
      {
         SFNode .initWithProxy (JSContext .current (), field: X3D .SFNode (wrappedValue: route .destinationNode))
      }
      
      dynamic public final var destinationField : String { route .destinationField! .getName () }

      // Input/Output
      
      public final func toString () -> String
      {
         return "[object X3DRoute]"
      }
   }
}
