//
//  X3DFontStyleNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DFontStyleNode :
   X3DNode
{
   // Fields

   @SFString public final var language    : String = ""
   @MFString public final var family      : MFString .Value = ["SERIF"]
   @SFString public final var style       : String = "PLAIN"
   @SFFloat  public final var spacing     : Float = 1
   @SFBool   public final var horizontal  : Bool = true
   @SFBool   public final var leftToRight : Bool = true
   @SFBool   public final var topToBottom : Bool = true
   @MFString public final var justify     : MFString .Value = ["BEGIN"]

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DFontStyleNode)
   }
}
