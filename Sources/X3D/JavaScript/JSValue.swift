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
   static func getValue (_ context : Context, _ field : X3D .X3DField) -> Any
   {
      switch field .getType ()
      {
         case .SFBool:      return (field as! X3D .SFBool)   .wrappedValue
         case .SFDouble:    return (field as! X3D .SFDouble) .wrappedValue
         case .SFFloat:     return (field as! X3D .SFFloat)  .wrappedValue
         case .SFInt32:     return (field as! X3D .SFInt32)  .wrappedValue
         case .SFString:    return (field as! X3D .SFString) .wrappedValue
         case .SFTime:      return (field as! X3D .SFTime)   .wrappedValue
         
         case .SFColor:     return SFColor     (context .context, object: (field as! X3D .SFColor))
         case .SFColorRGBA: return SFColorRGBA (context .context, object: (field as! X3D .SFColorRGBA))
         case .SFImage:     return SFImage     (context .context, object: (field as! X3D .SFImage))
         case .SFMatrix3d:  return SFMatrix3d  (context .context, object: (field as! X3D .SFMatrix3d))
         case .SFMatrix3f:  return SFMatrix3f  (context .context, object: (field as! X3D .SFMatrix3f))
         case .SFMatrix4d:  return SFMatrix4d  (context .context, object: (field as! X3D .SFMatrix4d))
         case .SFMatrix4f:  return SFMatrix4f  (context .context, object: (field as! X3D .SFMatrix4f))
         case .SFRotation:  return SFRotation  (context .context, object: (field as! X3D .SFRotation))
         case .SFVec2d:     return SFVec2d     (context .context, object: (field as! X3D .SFVec2d))
         case .SFVec2f:     return SFVec2f     (context .context, object: (field as! X3D .SFVec2f))
         case .SFVec3d:     return SFVec3d     (context .context, object: (field as! X3D .SFVec3d))
         case .SFVec3f:     return SFVec3f     (context .context, object: (field as! X3D .SFVec3f))
         case .SFVec4d:     return SFVec4d     (context .context, object: (field as! X3D .SFVec4d))
         case .SFVec4f:     return SFVec4f     (context .context, object: (field as! X3D .SFVec4f))
         
         case .SFNode: do
         {
            let field = field as! X3D .SFNode <X3D .X3DNode>
            let node  = field .wrappedValue
            
            guard node != nil else
            {
               return JSValue (nullIn: context .context)!
            }
            
            if let object = context .cache .object (forKey: node)
            {
               return object
            }
            
            let object = SFNode .initWithProxy (object: field)!

            context .cache .setObject (object, forKey: node)
            
            return object
         }
         
         case .MFBool:      return MFBool      .initWithProxy (object: (field as! X3D .MFBool))!
         case .MFDouble:    return MFDouble    .initWithProxy (object: (field as! X3D .MFDouble))!
         case .MFFloat:     return MFFloat     .initWithProxy (object: (field as! X3D .MFFloat))!
         case .MFInt32:     return MFInt32     .initWithProxy (object: (field as! X3D .MFInt32))!
         case .MFString:    return MFString    .initWithProxy (object: (field as! X3D .MFString))!
         case .MFTime:      return MFTime      .initWithProxy (object: (field as! X3D .MFTime))!
         
         case .MFColor:     return MFColor     .initWithProxy (object: (field as! X3D .MFColor))!
         case .MFColorRGBA: return MFColorRGBA .initWithProxy (object: (field as! X3D .MFColorRGBA))!
         case .MFImage:     return MFImage     .initWithProxy (object: (field as! X3D .MFImage))!
         case .MFMatrix3d:  return MFMatrix3d  .initWithProxy (object: (field as! X3D .MFMatrix3d))!
         case .MFMatrix3f:  return MFMatrix3f  .initWithProxy (object: (field as! X3D .MFMatrix3f))!
         case .MFMatrix4d:  return MFMatrix4d  .initWithProxy (object: (field as! X3D .MFMatrix4d))!
         case .MFMatrix4f:  return MFMatrix4f  .initWithProxy (object: (field as! X3D .MFMatrix4f))!
         case .MFRotation:  return MFRotation  .initWithProxy (object: (field as! X3D .MFRotation))!
         case .MFVec2d:     return MFVec2d     .initWithProxy (object: (field as! X3D .MFVec2d))!
         case .MFVec2f:     return MFVec2f     .initWithProxy (object: (field as! X3D .MFVec2f))!
         case .MFVec3d:     return MFVec3d     .initWithProxy (object: (field as! X3D .MFVec3d))!
         case .MFVec3f:     return MFVec3f     .initWithProxy (object: (field as! X3D .MFVec3f))!
         case .MFVec4d:     return MFVec4d     .initWithProxy (object: (field as! X3D .MFVec4d))!
         case .MFVec4f:     return MFVec4f     .initWithProxy (object: (field as! X3D .MFVec4f))!
            
         case .MFNode:      return MFNode      .initWithProxy (object: (field as! X3D .MFNode))!
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
         
         case .SFNode: do
         {
            if let value = value as? SFNode { (field as! X3D .SFNode <X3D .X3DNode>) .wrappedValue = value .object .wrappedValue }
            else { (field as! X3D .SFNode <X3D .X3DNode>) .wrappedValue = nil }
         }
            
         case .MFBool:      if let value = value as? MFBool      { (field as! X3D .MFBool)      .wrappedValue = value .object .wrappedValue }
         case .MFDouble:    if let value = value as? MFDouble    { (field as! X3D .MFDouble)    .wrappedValue = value .object .wrappedValue }
         case .MFFloat:     if let value = value as? MFFloat     { (field as! X3D .MFFloat)     .wrappedValue = value .object .wrappedValue }
         case .MFInt32:     if let value = value as? MFInt32     { (field as! X3D .MFInt32)     .wrappedValue = value .object .wrappedValue }
         case .MFString:    if let value = value as? MFString    { (field as! X3D .MFString)    .wrappedValue = value .object .wrappedValue }
         case .MFTime:      if let value = value as? MFTime      { (field as! X3D .MFTime)      .wrappedValue = value .object .wrappedValue }
         
         case .MFColor:     if let value = value as? MFColor     { (field as! X3D .MFColor)     .wrappedValue = value .object .wrappedValue }
         case .MFColorRGBA: if let value = value as? MFColorRGBA { (field as! X3D .MFColorRGBA) .wrappedValue = value .object .wrappedValue }
         case .MFImage:     if let value = value as? MFImage     { (field as! X3D .MFImage)     .wrappedValue = value .object .wrappedValue }
         case .MFMatrix3d:  if let value = value as? MFMatrix3d  { (field as! X3D .MFMatrix3d)  .wrappedValue = value .object .wrappedValue }
         case .MFMatrix3f:  if let value = value as? MFMatrix3f  { (field as! X3D .MFMatrix3f)  .wrappedValue = value .object .wrappedValue }
         case .MFMatrix4d:  if let value = value as? MFMatrix4d  { (field as! X3D .MFMatrix4d)  .wrappedValue = value .object .wrappedValue }
         case .MFMatrix4f:  if let value = value as? MFMatrix4f  { (field as! X3D .MFMatrix4f)  .wrappedValue = value .object .wrappedValue }
         case .MFRotation:  if let value = value as? MFRotation  { (field as! X3D .MFRotation)  .wrappedValue = value .object .wrappedValue }
         case .MFVec2d:     if let value = value as? MFVec2d     { (field as! X3D .MFVec2d)     .wrappedValue = value .object .wrappedValue }
         case .MFVec2f:     if let value = value as? MFVec2f     { (field as! X3D .MFVec2f)     .wrappedValue = value .object .wrappedValue }
         case .MFVec3d:     if let value = value as? MFVec3d     { (field as! X3D .MFVec3d)     .wrappedValue = value .object .wrappedValue }
         case .MFVec3f:     if let value = value as? MFVec3f     { (field as! X3D .MFVec3f)     .wrappedValue = value .object .wrappedValue }
         case .MFVec4d:     if let value = value as? MFVec4d     { (field as! X3D .MFVec4d)     .wrappedValue = value .object .wrappedValue }
         case .MFVec4f:     if let value = value as? MFVec4f     { (field as! X3D .MFVec4f)     .wrappedValue = value .object .wrappedValue }

         case .MFNode: if let value = value as? MFNode { (field as! X3D .MFNode <X3D .X3DNode>) .wrappedValue = value .object .wrappedValue }
      }
   }
}
