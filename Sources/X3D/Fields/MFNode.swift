//
//  MFNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFNode <Element : X3DBaseNode> :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Element
   public typealias Value   = [Element?]

   // Property wrapper handling
   
   public final var projectedValue : MFNode { self }
   public final var wrappedValue   : Value
   {
      willSet
      {
         let difference = newValue .difference (from: wrappedValue)
         
         for change in difference
         {
            switch change
            {
               case let .insert (_, newElement, _):
                  newElement? .addParent (self)
               default:
                  break
            }
         }

         for change in difference
         {
            switch change
            {
              case let .remove (_, oldElement, _):
                  oldElement? .removeParent (self)
               default:
                  break
            }
         }
      }
      
      didSet { addEvent () }
   }

   // Common properties
   
   internal final override class var typeName : String { "MFNode" }
   internal final override class var type     : X3DFieldType { .MFNode }

   // Construction

   required public override init ()
   {
      self .wrappedValue = [ ]
      
      super .init ()
   }
   
   public convenience init (wrappedValue : Value)
   {
      self .init ()

      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFNode { MFNode (wrappedValue: wrappedValue) }

   // Value handling
   
   public final override func equals (to field : X3DField) -> Bool
   {
      guard let field = field as? Self else { return false }
      
      return wrappedValue == field .wrappedValue
   }

   internal final override func set (value field : X3DField)
   {
      guard let field = field as? Self else { return }

      wrappedValue = field .wrappedValue
   }
   
   internal final override func set (with protoInstance : X3DPrototypeInstance, value field : X3DField)
      where Element == X3DNode
   {
      guard let field = field as? Self else { return }
      
      wrappedValue = field .wrappedValue .map
      {
         $0? .copy (with: protoInstance)
      }
   }
   
   // Input/Output
   
   internal final override func toStream (_ stream : X3DOutputStream)
   {
      switch wrappedValue .count
      {
         case 0:
            stream += "[ ]"
         case 1:
            stream += wrappedValue .first!? .toString () ?? "NULL"
         default:
            stream += "[\(wrappedValue .map { $0? .toString () ?? "NULL" } .joined (separator: ", "))]"
      }
   }
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      switch wrappedValue .count
      {
         case 0: do
         {
            break
         }
         case 1: do
         {
            if wrappedValue .first! != nil
            {
               wrappedValue .first!! .toXMLStream (stream)
            }
            else
            {
               stream += "<!-- NULL -->"
            }
         }
         default: do
         {
            stream += "["
            
            for node in wrappedValue
            {
               if node != nil
               {
                  node! .toVRMLStream (stream)
               }
               else
               {
                  stream += "<!-- NULL -->"
               }
            }
            
            stream += "]"
         }
      }
   }

   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      switch wrappedValue .count
      {
         case 0: do
         {
            stream += "["
            stream += stream .TidySpace
            stream += "]"
         }
         case 1: do
         {
            if let node = wrappedValue .first!
            {
               node .toVRMLStream (stream)
            }
            else
            {
               stream += "NULL"
            }
         }
         default: do
         {
            stream += "["
            stream += stream .TidyBreak
            
            stream .incIndent ()
            
            for node in wrappedValue
            {
               stream += stream .indent
               
               if let node = node
               {
                  node .toVRMLStream (stream)
                  
                  stream += stream .TidyBreak
              }
               else
               {
                  stream += "NULL"
                  stream += stream .Break
               }
            }
            
            stream .decIndent ()
            
            stream += stream .indent
            stream += "]"
         }
      }
   }
}
