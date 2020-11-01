//
//  X3DNurbsControlCurveNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DNurbsControlCurveNode :
   X3DNode
{
   // Fields

   @MFVec2d public final var controlPoint : MFVec2d .Value

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DNurbsControlCurveNode)
   }
}
