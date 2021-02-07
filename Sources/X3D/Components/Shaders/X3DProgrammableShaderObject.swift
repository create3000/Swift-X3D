//
//  X3DProgrammableShaderObject.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public protocol X3DProgrammableShaderObject :
   X3DNode
{ }

extension X3DProgrammableShaderObject
{
   // Construction
   
   internal func initProgrammableShaderObject ()
   {
      types .append (.X3DProgrammableShaderObject)
   }
}
