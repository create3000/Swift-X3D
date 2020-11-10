//
//  SupportedFields.swift
//  X3D
//
//  Created by Holger Seelig on 27.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class SupportedFields
{
   // Public properties

   internal static let fields : [String : X3DFieldInterface .Type] = [
      "SFBool"      : SFBool           .self,
      "SFColor"     : SFColor          .self,
      "SFColorRGBA" : SFColorRGBA      .self,
      "SFDouble"    : SFDouble         .self,
      "SFFloat"     : SFFloat          .self,
      "SFImage"     : SFImage          .self,
      "SFInt32"     : SFInt32          .self,
      "SFMatrix3d"  : SFMatrix3d       .self,
      "SFMatrix3f"  : SFMatrix3f       .self,
      "SFMatrix4d"  : SFMatrix4d       .self,
      "SFMatrix4f"  : SFMatrix4f       .self,
      "SFNode"      : SFNode <X3DNode> .self,
      "SFRotation"  : SFRotation       .self,
      "SFString"    : SFString         .self,
      "SFTime"      : SFTime           .self,
      "SFVec2d"     : SFVec2d          .self,
      "SFVec2f"     : SFVec2f          .self,
      "SFVec3d"     : SFVec3d          .self,
      "SFVec3f"     : SFVec3f          .self,
      "SFVec4d"     : SFVec4d          .self,
      "SFVec4f"     : SFVec4f          .self,

      "MFBool"      : MFBool           .self,
      "MFColor"     : MFColor          .self,
      "MFColorRGBA" : MFColorRGBA      .self,
      "MFDouble"    : MFDouble         .self,
      "MFFloat"     : MFFloat          .self,
      "MFImage"     : MFImage          .self,
      "MFInt32"     : MFInt32          .self,
      "MFMatrix3d"  : MFMatrix3d       .self,
      "MFMatrix3f"  : MFMatrix3f       .self,
      "MFMatrix4d"  : MFMatrix4d       .self,
      "MFMatrix4f"  : MFMatrix4f       .self,
      "MFNode"      : MFNode <X3DNode> .self,
      "MFRotation"  : MFRotation       .self,
      "MFString"    : MFString         .self,
      "MFTime"      : MFTime           .self,
      "MFVec2d"     : MFVec2d          .self,
      "MFVec2f"     : MFVec2f          .self,
      "MFVec3d"     : MFVec3d          .self,
      "MFVec3f"     : MFVec3f          .self,
      "MFVec4d"     : MFVec4d          .self,
      "MFVec4f"     : MFVec4f          .self,
   ]
}
