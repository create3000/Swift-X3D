//
//  JSX3DArrayField.swift
//
//
//  Created by Holger Seelig on 25.11.20.
//

import JavaScriptCore

@objc internal protocol X3DArrayFieldExports :
   JSExport
{ }

extension JavaScript
{
   @objc internal class X3DArrayField :
      X3DField,
      X3DArrayFieldExports
   {
      // Registration
      
      internal override class func register (_ context : JSContext)
      {
         context ["X3DArrayField"] = Self .self
      }
      
      // Construction
      
      internal init (_ object : X3D .X3DArrayField)
      {
         super .init (object)
      }
   }
}
