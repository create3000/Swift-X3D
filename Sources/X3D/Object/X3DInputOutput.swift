//
//  X3DInputOutput.swift
//  X3D
//
//  Created by Holger Seelig on 13.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public typealias X3DRequester = () -> Void

public protocol X3DInputOutput :
   class
{ }

extension X3DInputOutput
{
   public func addInterest <Object : X3DInputOutput> (_ method : @escaping (Object) -> X3DRequester, _ object : Object)
   {
      interestsSemaphore .wait ()

      let id        = peekFunc (method)
      let requester = { [weak object] in method (object!) () }
      
      interests .outputInterests .removeAll (where: { $0 .id == id && $0 .input === object })
      interests .outputInterests .append (X3DOutputInterest (id: id, input: object, requester: requester))
      
      interestsSemaphore .signal ()
   }

   public func removeInterest <Object : X3DInputOutput> (_ method : @escaping (Object) -> X3DRequester, _ object : Object)
   {
      interestsSemaphore .wait ()

      let id = peekFunc (method)

      interests .outputInterests .removeAll (where: { $0 .id == id && $0 .input === object })
      
      interestsSemaphore .signal ()
   }

   internal func processInterests ()
   {
      interestsSemaphore .wait ()

      let interests = self .interests
      var index     = 0
      
      for outputInterest in interests .outputInterests
      {
         if outputInterest .input != nil
         {
            outputInterest .requester ()
            index += 1
         }
         else
         {
            interests .outputInterests .remove (at: index)
         }
      }
      
      interestsSemaphore .signal ()
   }

   private var interests : X3DInterests
   {
      if let interests = interestsIndex .object (forKey: self)
      {
         return interests
      }
      
      let interests = X3DInterests ()

      interestsIndex .setObject (interests, forKey: self)
      
      return interests
   }
   
   internal var outputInterests : Int { interests .outputInterests .count }
}

// Function id peeker

internal func peekFunc <Arguments, Result> (_ f : @escaping (Arguments) -> Result) -> Int
{
   typealias IntInt = (Int, Int)
   
   let (_, lo) = unsafeBitCast (f, to: IntInt .self)
   let offset  = MemoryLayout <Int> .size == 8 ? 16 : 12
   let ptr     = UnsafePointer <Int> (bitPattern: lo + offset)!

   return ptr .pointee
}

// Static interests

fileprivate let interestsSemaphore = RecursiveDispatchSemaphore ()
fileprivate var interestsIndex     = X3DInterestIndices (keyOptions: .weakMemory, valueOptions: .strongMemory)

fileprivate typealias X3DInterestIndices = NSMapTable <AnyObject, X3DInterests>

fileprivate class X3DInterests
{
   fileprivate final var outputInterests = [X3DOutputInterest] ()
}

fileprivate struct X3DOutputInterest
{
   fileprivate var id         : Int
   fileprivate weak var input : X3DInputOutput?
   fileprivate var requester  : X3DRequester
}

// Semaphore

fileprivate final class Atomic <A>
{
   private let queue = DispatchQueue(label: "Atomic serial queue")
   private var _value : A
   
   init (_ value : A)
   {
      self ._value = value
   }

   var value : A { queue .sync { self ._value } }

   func mutate (_ transform : (inout A) -> ())
   {
      queue .sync { transform (&self ._value) }
   }
}

fileprivate final class RecursiveDispatchSemaphore
{
   private let semaphore = DispatchSemaphore (value: 1)
   private var thread    = Atomic <Thread?> (nil)
   private var count     = 0

   public func wait ()
   {
      if thread .value !== Thread .current
      {
         semaphore .wait ()
         
         thread .mutate { $0 = Thread .current }
      }
      
      count += 1
   }
   
   public func signal ()
   {
      count -= 1
      
      if count == 0
      {
         thread .mutate { $0 = nil }

         semaphore .signal ()
      }
   }
}
