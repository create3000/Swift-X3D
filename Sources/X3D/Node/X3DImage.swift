//
//  X3DImage.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DImage :
   X3DChildObject
{
   // Construction
   
   internal override init ()
   {
      super .init ()
      
      $array .addParent (self)
   }

   public final func copy () -> X3DImage
   {
      let copy = X3DImage ()
      
      copy .width  = width
      copy .height = height
      copy .comp   = comp
      
      for i in 0 ..< array .count
      {
         copy .array [i] = array [i]
      }
      
      return copy
   }
   
   // Equatable
   
   public static func == (lhs : X3DImage, rhs : X3DImage) -> Bool
   {
      return (
         lhs .width  == rhs .width  &&
         lhs .height == rhs .height &&
         lhs .comp   == rhs .comp   &&
         lhs .array  == rhs .array
      )
   }
   
   // Properties
   
   public var width : Int32 = 0
   {
      didSet
      {
         array .resize (Int (width * height), fillWith: 0)
         
         addEvent ()
      }
   }
   
   public var height : Int32 = 0
   {
      didSet
      {
         array .resize (Int (width * height), fillWith: 0)
         
         addEvent ()
      }
   }

   public var comp : Int32 = 0
   {
      didSet { addEvent () }
   }

   @MFInt32 public var array : [Int32]
   {
      didSet
      {
         let count = Int (width * height)
         
         guard array .count != count else { return }
         
         array .resize (count, fillWith: 0)
      }
   }
}
