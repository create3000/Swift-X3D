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
   
   public final override var count : Int { wrappedValue .count }

   // Input/Output
   
   internal final override func toStream (_ stream : X3DOutputStream)
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
               stream .enterScope ()
               
               node .toStream (stream)
               
               stream .leaveScope ()
            }
            else
            {
               stream += "NULL"
            }
         }
         default: do
         {
            stream .enterScope ()
            
            stream += "["
            stream += stream .TidyBreak
            stream += stream .IncIndent ()
            
            for node in wrappedValue
            {
               stream += stream .Indent
               
               if let node = node
               {
                  node .toStream (stream)
                  
                  stream += stream .TidyBreak
              }
               else
               {
                  stream += "NULL"
                  stream += stream .Break
               }
            }
            
            stream += stream .DecIndent ()
            stream += stream .Indent
            stream += "]"
            stream .leaveScope ()
         }
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
               stream .enterScope ()
               stream += stream .toXMLStream (wrappedValue .first!!)
               stream += stream .TidyBreak

               stream .leaveScope ()
            }
            else
            {
               stream += stream .Indent
               stream += "<!-- NULL -->"
               stream += stream .TidyBreak
            }
         }
         default: do
         {
            stream .enterScope ()
            
            for node in wrappedValue
            {
               if let node = node
               {
                  stream += stream .toXMLStream (node)
                  stream += stream .TidyBreak
               }
               else
               {
                  stream += stream .Indent
                  stream += "<!-- NULL -->"
                  stream += stream .TidyBreak
               }
            }
             
            stream .leaveScope ()
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
               stream .enterScope ()
               
               stream += stream .toVRMLStream (node)
      
               stream .leaveScope ()
            }
            else
            {
               stream += "NULL"
            }
         }
         default: do
         {
            stream .enterScope ()
            
            stream += "["
            stream += stream .TidyBreak
            stream += stream .IncIndent ()
            
            for node in wrappedValue
            {
               stream += stream .Indent
               
               if let node = node
               {
                  let use = stream .existsNode (node)
                  
                  stream += stream .toVRMLStream (node)
                  stream += use ? stream .Break : stream .TidyBreak
              }
               else
               {
                  stream += "NULL"
                  stream += stream .Break
               }
            }
            
            stream += stream .DecIndent ()
            stream += stream .Indent
            stream += "]"
            stream .leaveScope ()
         }
      }
   }
}
