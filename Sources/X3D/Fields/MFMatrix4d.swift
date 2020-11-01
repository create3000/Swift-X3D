//
//  MFMatrix4d.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFMatrix4d :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Matrix4d
   public typealias Value   = X3DArray <Element>

   // Property wrapper handling
   
   public final var projectedValue : MFMatrix4d { self }
   public final var wrappedValue : Value { value }
   private final let value = Value ()

   // Common properties
   
   public final override class var typeName : String { "MFMatrix4d" }
   public final override class var type     : X3DFieldType { .MFMatrix4d }

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
   
   public final override func copy () -> MFMatrix4d { MFMatrix4d (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFMatrix4d else { return }

      value .set (field .value)
   }
}
