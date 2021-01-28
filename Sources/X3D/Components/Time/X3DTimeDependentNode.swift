//
//  X3DTimeDependentNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public protocol X3DTimeDependentNode :
   X3DNode
{
   // Fields

   //@SFBool public final var loop        : Bool = false
   //@SFTime public final var startTime   : TimeInterval = 0
   //@SFTime public final var resumeTime  : TimeInterval = 0
   //@SFTime public final var pauseTime   : TimeInterval = 0
   //@SFTime public final var stopTime    : TimeInterval = 0
   //@SFBool public final var isPaused    : Bool = false
   //@SFTime public final var elapsedTime : TimeInterval = 0

   var isLive      : Bool { get }
   var enabled     : Bool { get }
   var loop        : Bool { get set }
   var startTime   : TimeInterval { get set }
   var resumeTime  : TimeInterval { get set }
   var pauseTime   : TimeInterval { get set }
   var stopTime    : TimeInterval { get set }
   var isPaused    : Bool { get set }
   var isActive    : Bool { get set }
   var elapsedTime : TimeInterval { get set }
}

extension X3DTimeDependentNode
{
   // Properties
   
   fileprivate var timeDependentProperties : X3DTimeDependentProperties
   {
      if let properties = timeDependentPropertiesIndex .object (forKey: self)
      {
         return properties
      }
      
      let properties = X3DTimeDependentProperties ()

      timeDependentPropertiesIndex .setObject (properties, forKey: self)
      
      return properties
   }

   // Construction
   
   internal func initTimeDependentNode (set_start : @escaping X3DRequester,
                                        set_pause : @escaping X3DRequester,
                                        set_resume : @escaping X3DRequester,
                                        set_stop : @escaping X3DRequester,
                                        set_time : @escaping X3DRequester)
   {
      types .append (.X3DTimeDependentNode)
      
      // Event handler
      
      timeDependentProperties .set_start  = set_start
      timeDependentProperties .set_pause  = set_pause
      timeDependentProperties .set_resume = set_resume
      timeDependentProperties .set_stop   = set_stop
      timeDependentProperties .set_time   = set_time
   }
   
   internal func initializeTimeDependentNode ()
   {
      scene! .$isLive .addInterest ("set_live", { $0 .set_live () }, self)
      
      try! getField (name: "loop")       .addInterest ("set_loop",       { $0 .set_loop () },       self)
      try! getField (name: "startTime")  .addInterest ("set_startTime",  { $0 .set_startTime () },  self)
      try! getField (name: "resumeTime") .addInterest ("set_resumeTime", { $0 .set_resumeTime () }, self)
      try! getField (name: "pauseTime")  .addInterest ("set_pauseTime",  { $0 .set_pauseTime () },  self)
      try! getField (name: "stopTime")   .addInterest ("set_stopTime",   { $0 .set_stopTime () },   self)
      
      DispatchQueue .main .async
      {
         self .timeDependentProperties .startTime  = self .startTime
         self .timeDependentProperties .resumeTime = self .resumeTime
         self .timeDependentProperties .pauseTime  = self .pauseTime
         self .timeDependentProperties .stopTime   = self .stopTime

         self .set_loop ()
      }
   }
   
   // Event handler
   
   internal func set_live ()
   {
      guard let scene = scene else { return }
      
      if scene .isPrivate || scene .isLive || isLive
      {
         if timeDependentProperties .disabled
         {
            timeDependentProperties .disabled = false

            if isActive && !isPaused
            {
               real_resume ()
            }
         }
      }
      else
      {
         if !timeDependentProperties .disabled && isActive && !isPaused
         {
            timeDependentProperties .disabled = true
            
            real_pause ()
         }
      }
   }
   
   internal func set_enabled ()
   {
      if enabled
      {
         set_loop ()
      }
      else
      {
         stop ()
      }
   }

   private func set_loop ()
   {
      guard let browser = browser else { return }
      
      if enabled
      {
         if loop
         {
            if timeDependentProperties .stopTime <= timeDependentProperties .startTime
            {
               if timeDependentProperties .startTime <= browser .currentTime
               {
                  do_start ()
               }
            }
         }
      }
   }

   private func set_startTime ()
   {
      guard let browser = browser else { return }
      
      timeDependentProperties .startTime = startTime

      if enabled
      {
         timeDependentProperties .startTask? .cancel ()

         if timeDependentProperties .startTime <= browser .currentTime
         {
            do_start ()
         }
         else
         {
            timeDependentProperties .startTask = addTimeout (X3DTimeDependentNode .do_start, timeDependentProperties .startTime)
         }
      }
   }
   
   private func set_resumeTime ()
   {
      guard let browser = browser else { return }
      
      timeDependentProperties .resumeTime = resumeTime

      if enabled
      {
         timeDependentProperties .resumeTask? .cancel ()

         if timeDependentProperties .resumeTime <= timeDependentProperties .pauseTime
         {
            return
         }

         if timeDependentProperties .resumeTime <= browser .currentTime
         {
            do_resume ()
         }
         else
         {
            timeDependentProperties .resumeTask = addTimeout (X3DTimeDependentNode .do_resume, timeDependentProperties .resumeTime)
         }
      }
   }
   
   private func set_pauseTime ()
   {
      guard let browser = browser else { return }
      
      timeDependentProperties .pauseTime = pauseTime

      if enabled
      {
         timeDependentProperties .pauseTask? .cancel ()

         if timeDependentProperties .pauseTime <= timeDependentProperties .resumeTime
         {
            return
         }

         if timeDependentProperties .pauseTime <= browser .currentTime
         {
            do_pause ()
         }
         else
         {
            timeDependentProperties .pauseTask = addTimeout (X3DTimeDependentNode .do_pause, timeDependentProperties .pauseTime)
         }
      }
   }
   
   private func set_stopTime ()
   {
      guard let browser = browser else { return }
      
      timeDependentProperties .stopTime = stopTime

      if enabled
      {
         timeDependentProperties .stopTask? .cancel ()

         if timeDependentProperties .stopTime <= timeDependentProperties .startTime
         {
            return
         }

         if timeDependentProperties .stopTime <= browser .currentTime
         {
            do_stop ()
         }
         else
         {
            timeDependentProperties .stopTask = addTimeout (X3DTimeDependentNode .do_stop, timeDependentProperties .stopTime)
         }
      }
   }
   
   // Operations
   
   private func do_start ()
   {
      guard let browser = browser, let scene = scene else { return }
      
      if !isActive
      {
         resetElapsedTime ()

         // The event order below is very important.

         isActive = true

         timeDependentProperties .set_start! ()

         if scene .isLive || isLive
         {
            browser .addBrowserInterest (event: .Browser_Event, id: "set_time", method: { $0 .do_set_time () }, object: self)
         }
         else
         {
            timeDependentProperties .disabled = true
            
            real_pause ()
         }

         elapsedTime = 0
      }
   }
   
   private func do_pause ()
   {
      guard let browser = browser, let scene = scene else { return }
      
      if isActive && !isPaused
      {
         isPaused = true

         timeDependentProperties .pauseTime = browser .currentTime

         if scene .isLive || isLive
         {
            real_pause ()
         }
      }
   }

   private func real_pause ()
   {
      guard let browser = browser else { return }
      
      timeDependentProperties .pause = browser .currentTime

      timeDependentProperties .set_pause! ()

      browser .removeBrowserInterest (event: .Browser_Event, id: "set_time", object: self)
   }

   private func do_resume ()
   {
      guard let browser = browser, let scene = scene else { return }
      
      if isActive && isPaused
      {
         isPaused = false

         timeDependentProperties .resumeTime = browser .currentTime

         if scene .isLive || isLive
         {
            real_resume ()
         }
      }
   }
   
   private func real_resume ()
   {
      guard let browser = browser else { return }
      
      let interval = browser .currentTime - timeDependentProperties .pause

      timeDependentProperties .pauseInterval += interval

      timeDependentProperties .set_resume! ()

      browser .addBrowserInterest (event: .Browser_Event, id: "set_time", method: { $0 .do_set_time () }, object: self)
      browser .setNeedsDisplay ()
   }

   private func do_stop ()
   {
      stop ()
   }

   internal func stop ()
   {
      guard let browser = browser, let scene = scene else { return }
      
      if isActive
      {
         // The event order below is very important.

         timeDependentProperties .set_stop! ()

         elapsedTime = getElapsedTime ()

         if isPaused
         {
            isPaused = false
         }

         isActive = false

         if scene .isLive || isLive
         {
            browser .removeBrowserInterest (event: .Browser_Event, id: "set_time", object: self)
         }
      }
   }
   
   // Elapsed time handling
   
   internal func getElapsedTime () -> TimeInterval
   {
      guard let browser = browser else { return 0 }
      
      return browser .currentTime - timeDependentProperties .start - timeDependentProperties .pauseInterval
   }

   private func resetElapsedTime ()
   {
      timeDependentProperties .start         = browser! .currentTime
      timeDependentProperties .pause         = browser! .currentTime
      timeDependentProperties .pauseInterval = 0
   }

   // Timeout
   
   private func addTimeout (_ method : @escaping (X3DTimeDependentNode) -> () -> Void, _ time : TimeInterval) -> DispatchWorkItem
   {
      let task = DispatchWorkItem (qos: .userInteractive)
      {
         [weak self] in if let self = self
         {
            self .browser? .advanceTime ()
            method (self) ()
         }
      }
      
      let interval = time - (browser? .currentTime ?? 0)

      DispatchQueue .main .asyncAfter (deadline: .now () + interval, execute: task)
      
      return task
   }
   
   // Callbacks
   
   private func do_set_time ()
   {
      timeDependentProperties .set_time! ()
   }
}

fileprivate var timeDependentPropertiesIndex = X3DTimeDependentPropertiesIndex (keyOptions: .weakMemory, valueOptions: .strongMemory)

fileprivate typealias X3DTimeDependentPropertiesIndex = NSMapTable <AnyObject, X3DTimeDependentProperties>

fileprivate final class X3DTimeDependentProperties
{
   fileprivate final var startTime  : TimeInterval = 0
   fileprivate final var resumeTime : TimeInterval = 0
   fileprivate final var pauseTime  : TimeInterval = 0
   fileprivate final var stopTime   : TimeInterval = 0
   
   fileprivate final var start         : TimeInterval = 0
   fileprivate final var pause         : TimeInterval = 0
   fileprivate final var pauseInterval : TimeInterval = 0

   fileprivate final var disabled : Bool = false

   fileprivate final var startTask  : DispatchWorkItem?
   fileprivate final var resumeTask : DispatchWorkItem?
   fileprivate final var pauseTask  : DispatchWorkItem?
   fileprivate final var stopTask   : DispatchWorkItem?
   
   fileprivate final var set_start  : X3DRequester?
   fileprivate final var set_pause  : X3DRequester?
   fileprivate final var set_resume : X3DRequester?
   fileprivate final var set_stop   : X3DRequester?
   fileprivate final var set_time   : X3DRequester?
   
   deinit
   {
      startTask?  .cancel ()
      resumeTask? .cancel ()
      pauseTask?  .cancel ()
      stopTask?   .cancel ()
   }
}
