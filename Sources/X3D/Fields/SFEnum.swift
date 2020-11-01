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
   public final var wrappedValue : Value { get { value } set { value = newValue; addEvent () } }
   private final var value : Value

   // Common properties
   
   public final override class var typeName : String { "SFEnum" }
   public final override class var type     : X3DFieldType { .SFInt32 }

   // Construction

   public init (wrappedValue : Value)
   {
      value = wrappedValue
   }
   
   public final override func copy () -> SFEnum { SFEnum (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFEnum else { return }
      
      value = field .value
   }
}
