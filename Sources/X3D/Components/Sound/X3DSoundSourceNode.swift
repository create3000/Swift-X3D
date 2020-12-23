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
   
   internal func initSoundSourceNode (set_start : @escaping X3DRequester,
                                      set_pause : @escaping X3DRequester,
                                      set_resume : @escaping X3DRequester,
                                      set_stop : @escaping X3DRequester,
                                      set_time : @escaping X3DRequester)
   {
      initTimeDependentNode (set_start: set_start,
                             set_pause: set_pause,
                             set_resume: set_resume,
                             set_stop: set_stop,
                             set_time: set_time)
      
      types .append (.X3DSoundSourceNode)
   }
   
   internal func initializeSoundSourceNode ()
   {
      initializeTimeDependentNode ()
   }
}
