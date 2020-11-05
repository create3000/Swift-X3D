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
   public typealias Value   = X3DObjectArray <Element>

   // Property wrapper handling
   
   public final var projectedValue : MFNode { self }
   public final var wrappedValue : Value { value }
   private final let value = Value ()

   // Common properties
   
   public final override class var typeName : String { "MFNode" }
   public final override class var type     : X3DFieldType { .MFNode }

   // Construction

   public override init ()
   {
      super .init ()

      value .field = self
   }
   
   public convenience init <S> (wrappedValue : S)
      where Element? == S .Element, S : Sequence
   {
      self .init ()

      value .append (contentsOf: wrappedValue)
   }
   
   public final override func copy () -> MFNode { MFNode (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFNode else { return }

      value .set (field .value)
   }
   
   internal final override func set (with protoInstance : X3DPrototypeInstance, value field : X3DField)
      where Element == X3DNode
   {
      guard let field = field as? MFNode else { return }
      
      value .set (field .value .map
      {
         $0? .copy (with: protoInstance)
      })
   }
}
