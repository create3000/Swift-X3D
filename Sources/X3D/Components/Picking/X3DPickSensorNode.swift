//
//  X3DPickSensorNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DPickSensorNode :
   X3DChildNode,
   X3DSensorNode
{
   // Fields

   @SFBool   public final var enabled          : Bool = true
   @MFString public final var objectType       : MFString .Value = ["ALL"]
   @SFString public final var matchCriterion   : String = "MATCH_ANY"
   @SFString public final var intersectionType : String = "BOUNDS"
   @SFString public final var sortOrder        : String = "CLOSEST"
   @SFBool   public final var isActive         : Bool = false
   @SFNode   public final var pickingGeometry  : X3DNode?
   @MFNode   public final var pickTarget       : MFNode <X3DNode> .Value
   @MFNode   public final var pickedGeometry   : MFNode <X3DNode> .Value

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)
      
      initSensorNode ()

      types .append (.X3DPickSensorNode)
   }
}
