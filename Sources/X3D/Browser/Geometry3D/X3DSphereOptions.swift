//
//  X3DSphereOptions.swift
//  X3D
//
//  Created by Holger Seelig on 08.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal struct X3DSphereOptionsVertex
{
   internal var texCoord : Vector4f
   internal var point    : Vector3f
}

internal class X3DSphereOptions :
   X3DBaseNode
{
   internal var primitives : [X3DSphereOptionsVertex] { [ ] }
}
