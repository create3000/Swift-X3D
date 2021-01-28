//
//  X3DInputOutput.swift
//  X3D
//
//  Created by Holger Seelig on 13.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public protocol X3DInputOutput :
   class
{ }

extension X3DInputOutput
{
   public func addInterest <Requester : X3DInputOutput> (_ id : String, _ handler : @escaping (Requester) -> Void, _ requester : Requester)
   {
      let closure = { [weak requester] in handler (requester!) }
      
      interestsSemaphore .wait ()

      interests .outputInterests .removeAll (where: { $0 .id == id && $0 .requester === requester })
      interests .outputInterests .append (X3DOutputInterest (id: id, requester: requester, closure: closure))
      
      interestsSemaphore .signal ()
   }

   public func removeInterest <Requester : X3DInputOutput> (_ id : String, _ requester : Requester)
   {
      interestsSemaphore .wait ()
      
      interests .outputInterests .removeAll (where: { $0 .id == id && $0 .requester === requester })
      
      interestsSemaphore .signal ()
   }

   internal func processInterests ()
   {
      interestsSemaphore .wait ()

      let interests = self .interests
      var index     = 0
      
      // No need to copy output interests.
      for outputInterest in interests .outputInterests
      {
         if outputInterest .requester != nil
         {
            outputInterest .closure ()
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
   fileprivate var id             : String
   fileprivate weak var requester : X3DInputOutput?
   fileprivate var closure        : X3DClosure
}

internal typealias X3DClosure = () -> Void
