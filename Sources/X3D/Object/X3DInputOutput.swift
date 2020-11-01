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
      let id        = peekFunc (method)
      let requester = { [weak object] in method (object!) () }

      if Thread .isMainThread
      {
         self .interests .outputInterests .removeAll (where: { $0 .id == id && $0 .input === object })
         self .interests .outputInterests .append (X3DOutputInterest (id: id, input: object, requester: requester))
      }
      else
      {
         DispatchQueue .main .async
         {
            self .interests .outputInterests .removeAll (where: { $0 .id == id && $0 .input === object })
            self .interests .outputInterests .append (X3DOutputInterest (id: id, input: object, requester: requester))
         }
      }
   }

   public func removeInterest <Object : X3DInputOutput> (_ method : @escaping (Object) -> X3DRequester, _ object : Object)
   {
      let id = peekFunc (method)

      if Thread .isMainThread
      {
         self .interests .outputInterests .removeAll (where: { $0 .id == id && $0 .input === object })
      }
      else
      {
         DispatchQueue .main .async
         {
            self .interests .outputInterests .removeAll (where: { $0 .id == id && $0 .input === object })
         }
      }
   }

   internal func processInterests ()
   {
      let interests = self .interests
      var index     = 0
      
      for outputInterest in interests .outputInterests
      {
         if let _ = outputInterest .input
         {
            outputInterest .requester ()
            index += 1
         }
         else
         {
            interests .outputInterests .remove (at: index)
         }
      }
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
}

fileprivate var interestsIndex = X3DInterestIndices (keyOptions: .weakMemory, valueOptions: .strongMemory)

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

internal func peekFunc <Arguments, Result> (_ f : @escaping (Arguments) -> Result) -> Int
{
   typealias IntInt = (Int, Int)
   
   let (_, lo) = unsafeBitCast (f, to: IntInt .self)
   let offset  = MemoryLayout <Int> .size == 8 ? 16 : 12
   let ptr     = UnsafePointer <Int> (bitPattern: lo + offset)!

   return ptr .pointee
}
