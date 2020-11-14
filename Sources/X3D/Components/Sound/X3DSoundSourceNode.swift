//
//  X3DSoundSourceNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public protocol X3DSoundSourceNode :
   X3DTimeDependentNode
{
   // Fields

   //@SFString public final var description      : String = ""
   //@SFFloat  public final var pitch            : Float = 1
   //@SFBool   public final var isActive         : Bool = false
   //@SFTime   public final var duration_changed : TimeInterval = -1

   var description      : String { get set }
   var pitch            : Float { get set }
   var isActive         : Bool { get set }
   var duration_changed : TimeInterval { get set }
}

extension X3DSoundSourceNode
{
   // Construction
   
   internal func initSoundSourceNode ()
   {
      initTimeDependentNode ()
      
      types .append (.X3DSoundSourceNode)
   }
   
   internal func initializeSoundSourceNode ()
   {
      initializeTimeDependentNode ()
   }
}
