//
//  SFInt32.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFInt32 :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Int32
   
   // Property wrapper handling
   
   public final var projectedValue : SFInt32 { self }
   public final var wrappedValue : Value { get { value } set { value = newValue; addEvent () } }
   private final var value : Value

   // Common properties
   
   public final override class var typeName : String { "SFInt32" }
   public final override class var type     : X3DFieldType { .SFInt32 }

   // Construction
   
   public override init ()
   {
      value = 0
   }

   public init (wrappedValue : Value)
   {
      value = wrappedValue
   }
   
   public final override func copy () -> SFInt32 { SFInt32 (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFInt32 else { return }
      
      value = field .value
   }
}