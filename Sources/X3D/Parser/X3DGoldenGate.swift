//
//  X3DGoldenGate.swift
//  X3D
//
//  Created by Holger Seelig on 24.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public protocol X3DParserInterface
{
   init (scene : X3DScene, x3dSyntax : String)
   
   var isValid : Bool { get }
   
   func parseIntoScene () throws
}

public final class X3DGoldenGate
{
   static private var parsers : [X3DParserInterface .Type] = [
      XMLParser  .self,
      JSONParser .self,
      VRMLParser .self,
   ]
   
   public static func addParser (of type : X3DParserInterface .Type)
   {
      parsers .append (type)
   }
   
   internal static func parseIntoScene (scene : X3DScene, x3dSyntax : String) throws
   {
      for interface in parsers
      {
         let parser = interface .init (scene: scene, x3dSyntax: x3dSyntax)

         if parser .isValid
         {
            try parser .parseIntoScene ()
            return
         }
      }
      
      throw X3DError .INVALID_X3D ("Couldn't determine file type.")
   }
}
