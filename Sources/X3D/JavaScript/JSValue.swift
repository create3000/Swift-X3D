//
//  File.swift
//  
//
//  Created by Holger Seelig on 24.11.20.
//

import JavaScriptCore

extension JSValue
{
   internal func toFloat () -> Float
   {
      return Float (toDouble ())
   }
}

extension JavaScript
{
   static func toValue (_ field : X3D .X3DField) -> Any
   {
      switch field .getType ()
      {
         case .SFBool:     return (field as! X3D .SFBool) .wrappedValue
         case .SFDouble:   return (field as! X3D .SFDouble) .wrappedValue
         case .SFFloat:    return (field as! X3D .SFFloat) .wrappedValue
         case .SFInt32:    return (field as! X3D .SFInt32) .wrappedValue
         case .SFRotation: return SFRotation (object: (field as! X3D .SFRotation))
         case .SFString:   return (field as! X3D .SFString) .wrappedValue
         case .SFTime:     return (field as! X3D .SFTime) .wrappedValue
         case .SFVec2d:    return SFVec2d (object: (field as! X3D .SFVec2d))
         case .SFVec2f:    return SFVec2f (object: (field as! X3D .SFVec2f))
         case .SFVec3d:    return SFVec3d (object: (field as! X3D .SFVec3d))
         case .SFVec3f:    return SFVec3f (object: (field as! X3D .SFVec3f))
         case .SFVec4d:    return SFVec4d (object: (field as! X3D .SFVec4d))
         case .SFVec4f:    return SFVec4f (object: (field as! X3D .SFVec4f))
         default:
            return 0
      }
   }
}
