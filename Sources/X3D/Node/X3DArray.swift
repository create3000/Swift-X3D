//
//  X3DArray.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DArray <Element> :
   BidirectionalCollection,
   RandomAccessCollection,
   RangeReplaceableCollection,
   Sequence
{
   // Member types
   
   public typealias Element = Element
   public typealias Array   = ContiguousArray <Element>
   
   // Private members
   
   private final var array = Array ()
   internal final unowned var field : X3DArrayField!
   
   // Construction
   
   public init () { }
   
   // Subscript
   
   @inlinable
   public final subscript (index : Int32) -> Element
   {
      get { self [Int (index)] }
      set (newElement) { self [Int (index)] = newElement }
   }

   public final subscript (index : Int) -> Element
   {
      get
      {
         return array [index]
      }
      set (newElement)
      {
         array [index] = newElement
         
         field .addEvent ()
      }
   }
   
   // Inspecting an Array
   
   public final var isEmpty  : Bool { array .isEmpty }
   public final var count    : Int { array .count }
   public final var capacity : Int { array .capacity }

   // Adding Elements
   
   internal final func set (_ newElements : X3DArray)
   {
      array = newElements .array
   }
   
   public final func append (_ newElement : Element)
   {
      array .append (newElement)
      
      field .addEvent ()
   }

   public final func reserveCapacity (_ minimumCapacity : Int)
   {
      array .reserveCapacity (minimumCapacity)
   }
   
   public final func resize (_ size : Int, fillWith value : Element)
   {
      array .resize (size, fillWith: value)
      
      field .addEvent ()
   }

   // Combining Arrays
   
   public final func append <S> (contentsOf newElements : S)
      where Element == S .Element, S : Sequence
   {
      array .append (contentsOf: newElements)
      field .addEvent ()
   }
   
   // Removing Elements
   
   public final func removeAll (keepingCapacity keepCapacity : Bool = false)
   {
      array .removeAll (keepingCapacity: keepCapacity)
   }
   
   public final func removeSubrange (_ bounds : Range <Int>)
   {
      array .removeSubrange (bounds)
      field .addEvent ()
   }
   
   // Sequence
   
   public final func makeIterator () -> IndexingIterator <Array>
   {
      return array .makeIterator ()
   }
   
   // Manipulating Indices
   
   public final func index (before i: Int) -> Int
   {
      return array .index (before: i)
   }
   
   public final func index (after i: Int) -> Int
   {
      return array .index (after: i)
   }

   public final var startIndex : Int { get { array .startIndex } }
   public final var endIndex   : Int { get { array .endIndex } }
}

internal extension RangeReplaceableCollection
{
   mutating func resize (_ size : Int, fillWith value : Element)
   {
      let c = count
      
      if c < size
      {
         append (contentsOf: repeatElement (value, count: c .distance (to: size)))
      }
      else if c > size
      {
         let newEnd = index (startIndex, offsetBy: size)
         
         removeSubrange (newEnd ..< endIndex)
      }
   }
}

internal extension RandomAccessCollection
{
   func lowerBound (value : Element, comp : (Element, Element) -> Bool) -> Int
   {
      var first = startIndex
      var count = distance (from: startIndex, to: endIndex)

      while count > 0
      {
         var it   = first
         let step = count / 2

         it = index (it, offsetBy: step)
         
         if comp (self [it], value)
         {
            first  = index (it, offsetBy: 1)
            count -= step + 1;
         }
         else
         {
            count = step
         }
      }

      return distance (from: startIndex, to: first)
   }
   
   func upperBound (value : Element, comp : (Element, Element) -> Bool) -> Int
   {
      var first = startIndex
      var count = distance (from: startIndex, to: endIndex)

      while count > 0
      {
         var it   = first
         let step = count / 2

         it = index (it, offsetBy: step)
         
         if comp (value, self [it])
         {
            count = step
         }
         else
         {
            it     = index (it, offsetBy: 1)
            first  = it
            count -= step + 1
         }
      }

      return distance (from: startIndex, to: first)
   }
}
