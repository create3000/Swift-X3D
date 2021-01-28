//
//  MovieTexture.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class MovieTexture :
   X3DTexture2DNode,
   X3DSoundSourceNode,
   X3DUrlObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "MovieTexture" }
   internal final override class var component      : String { "Texturing" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "texture" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFBool   public final var isLive           : Bool = false
   @SFBool   public final var enabled          : Bool = true
   @SFString public final var description      : String = ""
   @MFString public final var url              : [String]
   @SFFloat  public final var speed            : Float = 1
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
   
   // X3DUrlObject
   
   public final var loadState = SFEnum <X3DLoadState> (wrappedValue: .NOT_STARTED_STATE)

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initSoundSourceNode (set_start:  { [unowned self] in self .set_start () },
                           set_pause:  { [unowned self] in self .set_pause () },
                           set_resume: { [unowned self] in self .set_resume () },
                           set_stop:   { [unowned self] in self .set_stop () },
                           set_time:   { [unowned self] in self .set_time () })
      
      initUrlObject ()
      
      types .append (.MovieTexture)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.inputOutput,    "description",       $description)
      addField (.inputOutput,    "url",               $url)
      addField (.inputOutput,    "speed",             $speed)
      addField (.inputOutput,    "pitch",             $pitch)
      addField (.inputOutput,    "loop",              $loop)
      addField (.inputOutput,    "startTime",         $startTime)
      addField (.inputOutput,    "resumeTime",        $resumeTime)
      addField (.inputOutput,    "pauseTime",         $pauseTime)
      addField (.inputOutput,    "stopTime",          $stopTime)
      addField (.outputOnly,     "isPaused",          $isPaused)
      addField (.outputOnly,     "isActive",          $isActive)
      addField (.outputOnly,     "elapsedTime",       $elapsedTime)
      addField (.outputOnly,     "duration_changed",  $duration_changed)
      addField (.initializeOnly, "repeatS",           $repeatS)
      addField (.initializeOnly, "repeatT",           $repeatT)
      addField (.initializeOnly, "textureProperties", $textureProperties)
      
      addChildObjects ($isLive,
                       $enabled,
                       loadState)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> MovieTexture
   {
      return MovieTexture (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      initializeSoundSourceNode ()
      
      $isLive  .addInterest ("set_live",    { $0 .set_live () },    self)
      $enabled .addInterest ("set_enabled", { $0 .set_enabled () }, self)
   }
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
   }
   
   // Property access
   
   public final override var checkTextureLoadState : X3DLoadState { checkLoadState }

   // Event handler
   
   public final func set_start () { }
   public final func set_pause () { }
   public final func set_resume () { }
   public final func set_stop () { }
   public final func set_time () { }
}
