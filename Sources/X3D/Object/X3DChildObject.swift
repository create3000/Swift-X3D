//
//  X3DChildObject.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public class X3DChildObject :
   X3DObject
{
   // Event handling
   
   /// Return true if this object was modified some times in the past.
   internal final var isSet : Bool = false
   
   /// Return true if this object was recently modified and needs to be processed.
   internal final var isTainted : Bool = false

   internal final func addEvent ()
   {
      isSet = true
      
      for parent in parents .allObjects
      {
         parent .addEvent (for: self)
      }
   }

   internal func addEvent (for object : X3DChildObject)
   {
      isSet = true
      
      for parent in parents .allObjects
      {
         parent .addEvent (for: self)
      }
   }
   
   internal func addEventObject (for field : X3DField, event : X3DEvent)
   {
      isSet = true
      
      for parent in parents .allObjects
      {
         parent .addEventObject (for: field, event: event)
      }
   }

   // Parent handling
   
   public private(set) final var parents = NSHashTable <X3DChildObject> (options: .weakMemory)

   internal final func addParent (_ parent : X3DChildObject)
   {
      parents .add (parent)
   }
   
   internal final func removeParent (_ parent : X3DChildObject)
   {
      parents .remove (parent)
   }
}
