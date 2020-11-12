//
//  X3DNoneViewer.swift
//  X3D
//
//  Created by Holger Seelig on 24.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

internal final class NoneViewer :
   X3DViewer
{
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
   }
}
