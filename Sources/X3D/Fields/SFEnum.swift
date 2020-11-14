//
//  SFEnum.swift
//  X3D
//
//  Created by Holger Seelig on 09.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFEnum <Type> :
   X3DField
{
   // Member types
   
   public typealias Value = Type
   
   // Property wrapper handling
   
   public final var projectedValue : SFEnum { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFEnum" }
   internal final override class var type     : X3DFieldType { .SFInt32 }

   // Construction

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFEnum { SFEnum (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFEnum else { return }
      
      wrappedValue = field .wrappedValue
   }
}
