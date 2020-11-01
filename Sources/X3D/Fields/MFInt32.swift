//
//  MFInt32.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFInt32 :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Int32
   public typealias Value   = X3DArray <Element>

   // Property wrapper handling
   
   public final var projectedValue : MFInt32 { self }
   public final var wrappedValue : Value { value }
   private final let value = Value ()

   // Common properties
   
   public final override class var typeName : String { "MFInt32" }
   public final override class var type     : X3DFieldType { .MFInt32 }

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
   
   public final override func copy () -> MFInt32 { MFInt32 (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFInt32 else { return }

      value .set (field .value)
   }
}
