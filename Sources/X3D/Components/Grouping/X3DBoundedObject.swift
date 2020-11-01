//
//  X3DBoundedObject.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public protocol X3DBoundedObject :
   X3DBaseNode
{
   // Fields

   //@SFVec3f public final var bboxSize   : Vector3f = Vector3f (-1, -1, -1)
   //@SFVec3f public final var bboxCenter : Vector3f = Vector3f .zero

   var bboxSize   : Vector3f { get set }
   var bboxCenter : Vector3f { get set }
   
   // Properties
   
   var bbox : Box3f { get }
}

extension X3DBoundedObject
{
   // Construction
   
   internal func initBoundedObject (bboxSize : SFVec3f, bboxCenter : SFVec3f)
   {
      types .append (.X3DBoundedObject)
      
      bboxSize   .unit = .length
      bboxCenter .unit = .length
   }
}
