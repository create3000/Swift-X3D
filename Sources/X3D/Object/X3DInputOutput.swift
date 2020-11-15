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
   public func addInterest <Object : X3DInputOutput> (_ id : String, _ method : @escaping (Object) -> X3DRequester, _ object : Object)
   {
      let requester = { [weak object] in method (object!) () }
      
      interestsSemaphore .wait ()

      interests .outputInterests .removeAll (where: { $0 .id == id && $0 .input === object })
      interests .outputInterests .append (X3DOutputInterest (id: id, input: object, requester: requester))
      
      interestsSemaphore .signal ()
   }

   public func removeInterest <Object : X3DInputOutput> (_ id : String, _ method : @escaping (Object) -> X3DRequester, _ object : Object)
   {
      interestsSemaphore .wait ()

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
   fileprivate var id         : String
   fileprivate weak var input : X3DInputOutput?
   fileprivate var requester  : X3DRequester
}

// Semaphore

fileprivate final class RecursiveDispatchSemaphore
{
   private let semaphore = DispatchSemaphore (value: 1)
   private var thread    = Atomic <Thread?> (nil)
   private var count     = 0

   public func wait ()
   {
      if thread .load !== Thread .current
      {
         semaphore .wait ()
         
         thread .store (Thread .current)
      }
      
      count += 1
   }
   
   public func signal ()
   {
      count -= 1
      
      if count == 0
      {
         thread .store (nil)

         semaphore .signal ()
      }
   }
}

fileprivate final class Atomic <Type>
{
   private let queue = DispatchQueue (label: "Atomic serial queue")
   private var value : Type
   
   init (_ value : Type)
   {
      self .value = value
   }

   var load : Type { queue .sync { self .value } }

   func store (_ value : Type)
   {
      queue .sync { self .value = value }
   }
}
