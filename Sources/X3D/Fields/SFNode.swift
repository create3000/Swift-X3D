//
//  X3DPtr.swift
//  X3D
//
//  Created by Holger Seelig on 08.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFNode <Type : X3DBaseNode> :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Type
   
   // Property wrapper handling
   
   public final var projectedValue : SFNode { self }
   public final var wrappedValue : Value! { get { value } set { value = newValue; addEvent () } }

   private final var value : Value!
   {
      willSet
      {
         guard newValue !== value else { return }
         
         if (newValue != nil)
         {
            newValue .addParent (self)
         }
         
         if (value != nil)
         {
            value .removeParent (self)
         }
      }
   }
   
   // Common properties
   
   internal final override class var typeName : String { "SFNode" }
   internal final override class var type     : X3DFieldType { .SFNode }

   // Construction
   
   public override init ()
   { }

   public init (wrappedValue : Value!)
   {
      value = wrappedValue
      
      super .init ()
      
      guard value != nil else { return }

      value .addParent (self)
   }
   
   public final override func copy () -> SFNode { SFNode (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFNode else { return }
      
      value = field .value
   }
   
   internal final override func set (with protoInstance : X3DPrototypeInstance, value field : X3DField)
      where Type == X3DNode
   {
      guard let field = field as? SFNode else { return }
      
      value = field .value? .copy (with: protoInstance)
   }
}
