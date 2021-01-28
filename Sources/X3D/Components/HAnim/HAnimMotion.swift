//
//  HAnimMotion.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class HAnimMotion :
   X3DChildNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "HAnimMotion" }
   internal final override class var component      : String { "HAnim" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "motions" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFString public final var channels        : String = ""
   @MFBool   public final var channelsEnabled : [Bool]
   @SFTime   public final var cycleTime       : TimeInterval = 0
   @SFString public final var description     : String = ""
   @SFTime   public final var elapsedTime     : TimeInterval = 0
   @SFBool   public final var enabled         : Bool = true
   @SFInt32  public final var frameCount      : Int32 = 0
   @SFTime   public final var frameDuration   : TimeInterval = 0.1
   @SFInt32  public final var frameIncrement  : Int32 = 1
   @SFInt32  public final var frameIndex      : Int32 = 0
   @MFString public final var joints          : [String]
   @SFInt32  public final var loa             : Int32 = -1
   @SFBool   public final var loop            : Bool = false
   @SFBool   public final var next            : Bool = false
   @SFBool   public final var previous        : Bool = false
   @MFFloat  public final var values          : [Float]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.HAnimMotion)

      addField (.inputOutput, "metadata",        $metadata)
      addField (.inputOutput, "channels",        $channels)
      addField (.inputOutput, "channelsEnabled", $channelsEnabled)
      addField (.outputOnly,  "cycleTime",       $cycleTime)
      addField (.inputOutput, "description",     $description)
      addField (.outputOnly,  "elapsedTime",     $elapsedTime)
      addField (.inputOutput, "enabled",         $enabled)
      addField (.outputOnly,  "frameCount",      $frameCount)
      addField (.inputOutput, "frameDuration",   $frameDuration)
      addField (.inputOutput, "frameIncrement",  $frameIncrement)
      addField (.inputOutput, "frameIndex",      $frameIndex)
      addField (.inputOutput, "joints",          $joints)
      addField (.inputOutput, "loa",             $loa)
      addField (.inputOutput, "loop",            $loop)
      addField (.inputOnly,   "next",            $next)
      addField (.inputOnly,   "previous",        $previous)
      addField (.inputOutput, "values",          $values)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> HAnimMotion
   {
      return HAnimMotion (with: executionContext)
   }
}
