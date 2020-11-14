//
//  AudioClip.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class AudioClip :
   X3DNode,
   X3DSoundSourceNode,
   X3DUrlObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "AudioClip" }
   internal final override class var component      : String { "Sound" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "source" }
   
   // Fields

   @SFBool   public final var isLive           : Bool = false
   @SFBool   public final var enabled          : Bool = true
   @SFString public final var description      : String = ""
   @MFString public final var url              : [String]
   @SFFloat  public final var pitch            : Float = 1
   @SFBool   public final var loop             : Bool = false
   @SFTime   public final var startTime        : TimeInterval = 0
   @SFTime   public final var resumeTime       : TimeInterval = 0
   @SFTime   public final var pauseTime        : TimeInterval = 0
   @SFTime   public final var stopTime         : TimeInterval = 0
   @SFBool   public final var isPaused         : Bool = false
   @SFBool   public final var isActive         : Bool = false
   @SFTime   public final var elapsedTime      : TimeInterval = 0
   @SFTime   public final var duration_changed : TimeInterval = -1
   
   // X3DTimeDependendNode
   
   public final let timeDependentProperties = X3DTimeDependentProperties ()
   
   // X3DUrlObject
   
   @SFEnum public final var loadState : X3DLoadState = .NOT_STARTED_STATE

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initSoundSourceNode ()
      initUrlObject ()

      types .append (.AudioClip)

      addField (.inputOutput, "metadata",         $metadata)
      addField (.inputOutput, "description",      $description)
      addField (.inputOutput, "url",              $url)
      addField (.inputOutput, "pitch",            $pitch)
      addField (.inputOutput, "loop",             $loop)
      addField (.inputOutput, "startTime",        $startTime)
      addField (.inputOutput, "resumeTime",       $resumeTime)
      addField (.inputOutput, "pauseTime",        $pauseTime)
      addField (.inputOutput, "stopTime",         $stopTime)
      addField (.outputOnly,  "isPaused",         $isPaused)
      addField (.outputOnly,  "isActive",         $isActive)
      addField (.outputOnly,  "elapsedTime",      $elapsedTime)
      addField (.outputOnly,  "duration_changed", $duration_changed)
      
      addChildObjects ($isLive,
                       $enabled)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> AudioClip
   {
      return AudioClip (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      initializeTimeDependentNode ()
      
      $isLive  .addInterest (X3DTimeDependentNode .set_live,    self)
      $enabled .addInterest (X3DTimeDependentNode .set_enabled, self)
   }
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
   }

   // Event handler
   
   public final func set_start () { }
   public final func set_pause () { }
   public final func set_resume () { }
   public final func set_stop () { }
   public final func set_time () { }
}
