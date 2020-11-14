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
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFEnum { self }
   public final var wrappedValue : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFEnum" }
   internal final override class var type     : X3DFieldType { .MFInt32 }

   // Construction
   
   public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFEnum { MFEnum (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFEnum else { return }

      wrappedValue = field .wrappedValue
   }
}
