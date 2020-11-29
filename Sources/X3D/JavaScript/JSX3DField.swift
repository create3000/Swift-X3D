//
//  JSX3DField.swift
//  
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol X3DFieldExports :
   JSExport
{
   func getName () -> String
   func getTypeName () -> String
   func getType () -> Int32
   func isReadable () -> JSValue
   func isWritable () -> JSValue

   func toString () -> String
}

extension JavaScript
{
   @objc internal class X3DField :
      NSObject,
      X3DFieldExports
   {
      // Registration
      
      internal class func register (_ context : JSContext)
      {
         context ["X3DField"] = Self .self
      }
      
      // Construction
      
      private final var field : X3D .X3DField
      
      internal init (_ field : X3D .X3DField)
      {
         self .field = field
      }

      // Common functions
      
      public final func getName () -> String { return field .getName () }
      
      public final func getTypeName () -> String { return field .getTypeName () }
      
      public final func getType () -> Int32 { return field .getType () .rawValue }
      
      public final func isReadable () -> JSValue
      {
         return JSValue (bool: field .getAccessType () != .inputOnly, in: JSContext .current ())
      }
      
      public final func isWritable () -> JSValue
      {
         return JSValue (bool: field .getAccessType () != .initializeOnly, in: JSContext .current ())
      }

      // Input/Output
      
      public final func toString () -> String
      {
         return field .toString ()
      }
   }
}
