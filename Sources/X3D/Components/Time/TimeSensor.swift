//
//  TimeSensor.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class TimeSensor :
   X3DChildNode,
   X3DTimeDependentNode,
   X3DSensorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TimeSensor" }
   internal final override class var component      : String { "Time" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }
   
   // Fields
   
   @SFBool  public final var isLive           : Bool = false
   @SFBool  public final var enabled          : Bool = true
   @SFTime  public final var cycleInterval    : TimeInterval = 1
   @MFFloat public final var range            : [Float] = [0, 0, 1] // [current, from, to] in fractions
   @SFBool  public final var loop             : Bool = false
   @SFTime  public final var startTime        : TimeInterval = 0
   @SFTime  public final var resumeTime       : TimeInterval = 0
   @SFTime  public final var pauseTime        : TimeInterval = 0
   @SFTime  public final var stopTime         : TimeInterval = 0
   @SFBool  public final var isPaused         : Bool = false
   @SFBool  public final var isActive         : Bool = false
   @SFTime  public final var cycleTime        : TimeInterval = 0
   @SFTime  public final var elapsedTime      : TimeInterval = 0
   @SFFloat public final var fraction_changed : Float = 0
   @SFTime  public final var time             : TimeInterval = 0
   
   // Properties

   private final var cycle    : TimeInterval = 0
   private final var interval : TimeInterval = 0
   private final var fraction : TimeInterval = 0
   private final var first    : TimeInterval = 0
   private final var last     : TimeInterval = 0
   private final var scale    : TimeInterval = 0

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initTimeDependentNode (set_start:  { [unowned self] in self .set_start () },
                             set_pause:  { [unowned self] in self .set_pause () },
                             set_resume: { [unowned self] in self .set_resume () },
                             set_stop:   { [unowned self] in self .set_stop () },
                             set_time:   { [unowned self] in self .set_time () })
      
      initSensorNode ()
      
      types .append (.TimeSensor)

      addField (.inputOutput, "metadata",         $metadata)
      addField (.inputOutput, "enabled",          $enabled)
      addField (.inputOutput, "cycleInterval",    $cycleInterval)
      addField (.inputOutput, "loop",             $loop)
      addField (.inputOutput, "startTime",        $startTime)
      addField (.inputOutput, "resumeTime",       $resumeTime)
      addField (.inputOutput, "pauseTime",        $pauseTime)
      addField (.inputOutput, "stopTime",         $stopTime)
      addField (.outputOnly,  "isPaused",         $isPaused)
      addField (.outputOnly,  "isActive",         $isActive)
      addField (.outputOnly,  "cycleTime",        $cycleTime)
      addField (.outputOnly,  "elapsedTime",      $elapsedTime)
      addField (.outputOnly,  "fraction_changed", $fraction_changed)
      addField (.outputOnly,  "time",             $time)
      
      addChildObjects ($isLive,
                       $range)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TimeSensor
   {
      return TimeSensor (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      initializeTimeDependentNode ()
      
      $isLive        .addInterest ("set_live",          { $0 .set_live () },          self)
      $enabled       .addInterest ("set_enabled",       { $0 .set_enabled () },       self)
      $cycleInterval .addInterest ("set_cycleInterval", { $0 .set_cycleInterval () }, self)
      $range         .addInterest ("set_range",         { $0 .set_range () },         self)
   }
   
   private final func setRange (_ currentFraction : Double, _ firstFraction : Double, _ lastFraction : Double)
   {
      let currentTime = browser! .currentTime
      
      first    = firstFraction
      last     = lastFraction
      scale    = last - first
      interval = cycleInterval * scale
      fraction = fract ((currentFraction >= 1 ? 0 : currentFraction) + (interval != 0 ? (currentTime - startTime) / interval : 0))
      cycle    = currentTime - (fraction - first) * cycleInterval
   }
   
   // Event handler
   
   private final func set_cycleInterval ()
   {
      if isActive
      {
         setRange (fraction, Double (range [1]), Double (range [2]))
      }
   }
   
   private final func set_range ()
   {
      if isActive
      {
         setRange (Double (range [0]), Double (range [1]), Double (range [2]))

         if !isPaused
         {
            set_fraction ()
         }
      }
   }

   public final func set_start ()
   {
      setRange (Double (range [0]), Double (range [1]), Double (range [2]))

      fraction_changed = Float (fraction)
      time             = browser! .currentTime
   }
   
   public final func set_pause () { }
   
   public final func set_resume ()
   {
      setRange (fract (fraction - (browser! .currentTime - startTime) / interval), Double (range [1]), Double (range [2]))
   }
   
   public final func set_stop () { }
   
   private final func set_fraction ()
   {
      fraction         = first + fract ((browser! .currentTime - cycle) / interval) * scale
      fraction_changed = Float (fraction)
   }
   
   public final func set_time ()
   {
      // The event order below is very important.

      if browser! .currentTime - cycle >= interval
      {
         if loop
         {
            if interval != 0
            {
               cycle += interval * floor ((browser! .currentTime - cycle) / interval)

               elapsedTime = getElapsedTime ()
               cycleTime   = browser! .currentTime

               set_fraction ()
            }
         }
         else
         {
            fraction         = last
            fraction_changed = Float (fraction)
            
            stop ()
         }
      }
      else
      {
         elapsedTime = getElapsedTime ()

         set_fraction ()
      }

      time = browser! .currentTime
   }
}
