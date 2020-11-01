//
//  X3DSequencerNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DSequencerNode :
   X3DChildNode
{
   // Fields

   @SFFloat public final var set_fraction : Float = 0
   @SFBool  public final var previous     : Bool = false
   @SFBool  public final var next         : Bool = false
   @MFFloat public final var key          : MFFloat .Value

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DSequencerNode)
   }
}
