//
//  X3DGoldenGate.swift
//  X3D
//
//  Created by Holger Seelig on 24.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

internal final class X3DGoldenGate
{
   internal static func parseIntoScene (scene : X3DScene, x3dSyntax : String) throws
   {
      do
      {
         let parser = X3DXMLParser (scene: scene, x3dSyntax: x3dSyntax)

         if parser .isXML
         {
            try parser .parseIntoScene ()
            return
         }
      }
      
      do
      {
         let parser = X3DVRMLParser (scene: scene, x3dSyntax: x3dSyntax)

         if parser .isVRML
         {
            try parser .parseIntoScene ()
            return
         }
      }
      
      throw X3DError .INVALID_X3D ("Couldn't determine file type.")
   }
}
