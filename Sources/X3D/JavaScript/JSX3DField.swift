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
   func isReadable () -> Any
   func isWritable () -> Any

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
         
         context .evaluateScript ("""
(function (targets)
{
   const getName     = X3DField .prototype .getName;
   const getTypeName = X3DField .prototype .getTypeName;
   const getType     = X3DField .prototype .getType;
   const isReadable  = X3DField .prototype .isReadable;
   const isWritable  = X3DField .prototype .isWritable;
   const toString    = X3DField .prototype .toString;

   X3DField .prototype .getName      = function () { return getName     .call (targets .get (this) || this) };
   X3DField .prototype .getTypeName  = function () { return getTypeName .call (targets .get (this) || this) };
   X3DField .prototype .getType      = function () { return getType     .call (targets .get (this) || this) };
   X3DField .prototype .isReadable   = function () { return isReadable  .call (targets .get (this) || this) };
   X3DField .prototype .isWritable   = function () { return isWritable  .call (targets .get (this) || this) };
   X3DField .prototype .toString     = function () { return toString    .call (targets .get (this) || this) };
})
(targets);
""")
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
      
      public final func isReadable () -> Any
      {
         return field .getAccessType () != .inputOnly
      }
      
      public final func isWritable () -> Any
      {
         return field .getAccessType () != .initializeOnly
      }

      // Input/Output
      
      public final func toString () -> String
      {
         return field .toString ()
      }
   }
}
