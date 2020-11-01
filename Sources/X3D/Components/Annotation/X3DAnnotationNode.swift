//
//  X3DAnnotationNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

//@SFBool   public final var enabled           : Bool = true
//@SFString public final var annotationGroupID : String = ""
//@SFString public final var displayPolicy     : String = "NEVER"

public protocol X3DAnnotationNode :
   X3DChildNode
{
   // Fields

   var enabled           : Bool { get set }
   var annotationGroupID : String { get set }
   var displayPolicy     : String { get set }
}

extension X3DAnnotationNode
{
   // Construction
   
   internal func initAnnotationNode ()
   {
      types .append (.X3DAnnotationNode)
   }
}
