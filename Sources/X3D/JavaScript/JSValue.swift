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
   static func getValue (_ context : JSContext, _ field : X3D .X3DField) -> Any
   {
      switch field .getType ()
      {
         case .SFBool:      return (field as! X3D .SFBool)   .wrappedValue
         case .SFDouble:    return (field as! X3D .SFDouble) .wrappedValue
         case .SFFloat:     return (field as! X3D .SFFloat)  .wrappedValue
         case .SFInt32:     return (field as! X3D .SFInt32)  .wrappedValue
         case .SFString:    return (field as! X3D .SFString) .wrappedValue
         case .SFTime:      return (field as! X3D .SFTime)   .wrappedValue
         
         case .SFColor:     return SFColor     (context, object: (field as! X3D .SFColor))
         case .SFColorRGBA: return SFColorRGBA (context, object: (field as! X3D .SFColorRGBA))
         case .SFImage:     return SFImage     (context, object: (field as! X3D .SFImage))
         case .SFMatrix3d:  return SFMatrix3d  (context, object: (field as! X3D .SFMatrix3d))
         case .SFMatrix3f:  return SFMatrix3f  (context, object: (field as! X3D .SFMatrix3f))
         case .SFMatrix4d:  return SFMatrix4d  (context, object: (field as! X3D .SFMatrix4d))
         case .SFMatrix4f:  return SFMatrix4f  (context, object: (field as! X3D .SFMatrix4f))
         case .SFRotation:  return SFRotation  (context, object: (field as! X3D .SFRotation))
         case .SFVec2d:     return SFVec2d     (context, object: (field as! X3D .SFVec2d))
         case .SFVec2f:     return SFVec2f     (context, object: (field as! X3D .SFVec2f))
         case .SFVec3d:     return SFVec3d     (context, object: (field as! X3D .SFVec3d))
         case .SFVec3f:     return SFVec3f     (context, object: (field as! X3D .SFVec3f))
         case .SFVec4d:     return SFVec4d     (context, object: (field as! X3D .SFVec4d))
         case .SFVec4f:     return SFVec4f     (context, object: (field as! X3D .SFVec4f))
         
         case .MFBool:      return MFBool .initWithProxy (object: (field as! X3D .MFBool))!

         default:
            return 0
      }
   }
   
   static func setValue (_ field : X3D .X3DField, _ value : Any)
   {
      switch field .getType ()
      {
         case .SFBool:      if let value = value as? Bool   { (field as! X3D .SFBool)   .wrappedValue = value }
         case .SFDouble:    if let value = value as? Double { (field as! X3D .SFDouble) .wrappedValue = value }
         case .SFFloat:     if let value = value as? Double { (field as! X3D .SFFloat)  .wrappedValue = Float (value) }
         case .SFInt32:     if let value = value as? Int32  { (field as! X3D .SFInt32)  .wrappedValue = value }
         case .SFString:    if let value = value as? String { (field as! X3D .SFString) .wrappedValue = value }
         case .SFTime:      if let value = value as? Double { (field as! X3D .SFTime)   .wrappedValue = value }
         
         case .SFColor:     if let value = value as? SFColor     { (field as! X3D .SFColor)     .wrappedValue = value .object .wrappedValue }
         case .SFColorRGBA: if let value = value as? SFColorRGBA { (field as! X3D .SFColorRGBA) .wrappedValue = value .object .wrappedValue }
         case .SFImage:     if let value = value as? SFImage     { (field as! X3D .SFImage)     .set (value: value .object) }
         case .SFMatrix3d:  if let value = value as? SFMatrix3d  { (field as! X3D .SFMatrix3d)  .wrappedValue = value .object .wrappedValue }
         case .SFMatrix3f:  if let value = value as? SFMatrix3f  { (field as! X3D .SFMatrix3f)  .wrappedValue = value .object .wrappedValue }
         case .SFMatrix4d:  if let value = value as? SFMatrix4d  { (field as! X3D .SFMatrix4d)  .wrappedValue = value .object .wrappedValue }
         case .SFMatrix4f:  if let value = value as? SFMatrix4f  { (field as! X3D .SFMatrix4f)  .wrappedValue = value .object .wrappedValue }
         case .SFRotation:  if let value = value as? SFRotation  { (field as! X3D .SFRotation)  .wrappedValue = value .object .wrappedValue }
         case .SFVec2d:     if let value = value as? SFVec2d     { (field as! X3D .SFVec2d)     .wrappedValue = value .object .wrappedValue }
         case .SFVec2f:     if let value = value as? SFVec2f     { (field as! X3D .SFVec2f)     .wrappedValue = value .object .wrappedValue }
         case .SFVec3d:     if let value = value as? SFVec3d     { (field as! X3D .SFVec3d)     .wrappedValue = value .object .wrappedValue }
         case .SFVec3f:     if let value = value as? SFVec3f     { (field as! X3D .SFVec3f)     .wrappedValue = value .object .wrappedValue }
         case .SFVec4d:     if let value = value as? SFVec4d     { (field as! X3D .SFVec4d)     .wrappedValue = value .object .wrappedValue }
         case .SFVec4f:     if let value = value as? SFVec4f     { (field as! X3D .SFVec4f)     .wrappedValue = value .object .wrappedValue }

         case .MFBool:      if let value = value as? MFBool      { (field as! X3D .MFBool)      .wrappedValue = value .object .wrappedValue }

         default:
            break
      }
   }
}
