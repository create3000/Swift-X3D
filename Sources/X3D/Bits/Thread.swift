//
//  File.swift
//  
//
//  Created by Holger Seelig on 15.11.20.
//

// Semaphore

internal final class RecursiveDispatchSemaphore
{
   private final let semaphore = DispatchSemaphore (value: 1)
   private final var thread    = Atomic <Thread?> (nil)
   private final var count     = 0

   public final func wait ()
   {
      if thread .load !== Thread .current
      {
         semaphore .wait ()
         
         thread .store (Thread .current)
      }
      
      count += 1
   }
   
   public final func signal ()
   {
      count -= 1
      
      if count == 0
      {
         thread .store (nil)

         semaphore .signal ()
      }
   }
}

internal final class Atomic <Type>
{
   private final let queue = DispatchQueue (label: "create3000.atomic")
   private final var value : Type
   
   public init (_ value : Type)
   {
      self .value = value
   }
   
   public final var load : Type { queue .sync { self .value } }
   
   public final func store (_ value : Type)
   {
      queue .sync { self .value = value }
   }
   
   public final func exchange (_ value : Type) -> Type
   {
      queue .sync
      {
         let oldValue = self .value
         
         self .value = value

         return oldValue
      }
   }
   
   public final func mutate (_ transform : (inout Type) -> ())
   {
      queue .sync { transform (&self .value) }
   }
}
