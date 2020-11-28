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
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFNode else { return }

      wrappedValue = field .wrappedValue
   }
   
   internal final override func set (with protoInstance : X3DPrototypeInstance, value field : X3DField)
      where Element == X3DNode
   {
      guard let field = field as? MFNode else { return }
      
      wrappedValue = field .wrappedValue .map
      {
         $0? .copy (with: protoInstance)
      }
   }
}
