//
//  X3DInputOutput.swift
//  X3D
//
//  Created by Holger Seelig on 13.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DInputOutput
{
   private final var interests = [X3DOutputInterest] ()
   
   public func addInterest <Requester : AnyObject> (_ id : String, _ handler : @escaping (Requester) -> Void, _ requester : Requester)
   {
      let closure = { [weak requester] in handler (requester!) }
 
      interests .removeAll (where: { $0 .id == id && $0 .requester === requester })
      interests .append (X3DOutputInterest (id: id, requester: requester, closure: closure))
   }

   public func removeInterest <Requester : AnyObject> (_ id : String, _ requester : Requester)
   {
      interests .removeAll (where: { $0 .id == id && $0 .requester === requester })
   }

   internal func processInterests ()
   {
      var index = 0
      
      // No need to copy output interests.
      for interest in interests
      {
         if interest .requester != nil
         {
            interest .closure ()
            index += 1
         }
         else
         {
            interests .remove (at: index)
         }
      }
   }
}

fileprivate struct X3DOutputInterest
{
   fileprivate var id             : String
   fileprivate weak var requester : AnyObject?
   fileprivate var closure        : X3DClosure
}

internal typealias X3DClosure = () -> Void
