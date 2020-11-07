//
//  MFEnum.swift
//  X3D
//
//  Created by Holger Seelig on 09.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFEnum <Type> :
   X3DArrayField
{
   // Member types
   
   public typealias Element = Type
   public typealias Value   = X3DArray <Element>

   // Property wrapper handling
   
   public final var projectedValue : MFEnum { self }
   public final var wrappedValue : Value { value }
   private final let value = Value ()

   // Common properties
   
   internal final override class var typeName : String { "MFEnum" }
   internal final override class var type     : X3DFieldType { .MFInt32 }

   // Construction
   
   public override init ()
   {
      super .init ()

      value .field = self
   }
   
   public convenience init <S> (wrappedValue : S)
      where Element == S .Element, S : Sequence
   {
      self .init ()

      value .append (contentsOf: wrappedValue)
   }
   
   public final override func copy () -> MFEnum { MFEnum (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFEnum else { return }

      value .set (field .value)
   }
}
