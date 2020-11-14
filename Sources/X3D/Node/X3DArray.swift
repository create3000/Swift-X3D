//
//  X3DNodeArray.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DArray <ElementT : X3DChildObject> :
   BidirectionalCollection,
   RandomAccessCollection,
   RangeReplaceableCollection,
   Sequence
{
   // Member types
   
   public typealias Element = ElementT?
   
   // Private members
   
   private final var array : [Element] = [ ]
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
         let element = array [index]
         
         if newElement !== element
         {
            newElement? .addParent (field)

            array [index] = newElement
            
            if array .reduce (0, { r, e in e === element ? r + 1 : r }) == 0
            {
               element? .removeParent (field)
            }
         }
         
         field .addEvent ()
      }
   }

   // Inspecting an Array
   
   public final var isEmpty  : Bool { array .isEmpty }
   public final var count    : Int { array .count }
   public final var capacity : Int { array .capacity }
   
   // Adding Elements
   
   internal final func set <BC> (_ newElements : BC)
      where Element == BC .Element, BC : BidirectionalCollection
   {
      let difference = newElements .difference (from: array)
      
      for change in difference
      {
         switch change
         {
            case let .insert (_, newElement, _):
               newElement? .addParent (field)
            default:
               break
         }
      }

      for change in difference
      {
         switch change
         {
           case let .remove (_, oldElement, _):
               oldElement? .removeParent (field)
            default:
               break
         }
      }
      
      for change in difference
      {
         switch change
         {
            case let .remove (offset, _, _):
               array .remove (at: offset)
            case let .insert (offset, newElement, _):
               array .insert (newElement, at: offset)
         }
      }
      
      field .addEvent ()
   }

   public final func append (_ newElement : Element)
   {
      newElement? .addParent (field)
      array .append (newElement)
      field .addEvent ()
   }
   
   public final func reserveCapacity (_ minimumCapacity : Int)
   {
      array .reserveCapacity (minimumCapacity)
   }
   
   public final func resize (_ size : Int, fillWith value : Element)
   {
      value? .addParent (field)
      
      array .resize (size, fillWith: value)
      
      field .addEvent ()
   }

   // Combining Arrays

   public final func append <S> (contentsOf newElements : S)
      where Element == S .Element, S : Sequence
   {
      for newElement in newElements
      {
         newElement? .addParent (field)
      }
      
      array .append (contentsOf: newElements)
      field .addEvent ()
   }
   
   // Removing Elements
   
   public final func removeAll (keepingCapacity keepCapacity : Bool = false)
   {
      for element in array
      {
         element? .removeParent (field)
      }

      array .removeAll (keepingCapacity: keepCapacity)
      field .addEvent ()
   }

   public final func removeSubrange (_ bounds : Range <Int>)
   {
      let oldElements = Array (array [bounds])
   
      array .removeSubrange (bounds)
   
      for oldElement in oldElements
      {
         if array .reduce (0, { r, e in e === oldElement ? r + 1 : r }) == 0
         {
            oldElement? .removeParent (field)
         }
      }
      
      field .addEvent ()
   }
   
   // Sequence
   
   public final func makeIterator () -> IndexingIterator <[Element]>
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
