//
//  MFTime.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

@propertyWrapper
public final class MFTime :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = TimeInterval
   public typealias Value   = X3DArray <Element>

   // Property wrapper handling
   
   public final var projectedValue : MFTime { self }
   public final var wrappedValue : Value { value }
   private final let value = Value ()

   // Common properties
   
   internal final override class var typeName : String { "MFTime" }
   internal final override class var type     : X3DFieldType { .MFTime }

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
   
   public final override func copy () -> MFTime { MFTime (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFTime else { return }

      value .set (field .value)
   }
}
