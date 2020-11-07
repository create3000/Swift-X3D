//
//  MFString.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFString :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = String
   public typealias Value   = X3DArray <Element>

   // Property wrapper handling
   
   public final var projectedValue : MFString { self }
   public final var wrappedValue : Value { value }
   private final let value = Value ()

   // Common properties
   
   internal final override class var typeName : String { "MFString" }
   internal final override class var type     : X3DFieldType { .MFString }

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
   
   public final override func copy () -> MFString { MFString (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFString else { return }

      value .set (field .value)
   }
}
