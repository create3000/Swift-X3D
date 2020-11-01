//
//  SFFloat.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFFloat :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Float
   
   // Property wrapper handling
   
   public final var projectedValue : SFFloat { self }
   public final var wrappedValue : Value { get { value } set { value = newValue; addEvent () } }
   private final var value : Value

   // Common properties
   
   public final override class var typeName : String { "SFFloat" }
   public final override class var type     : X3DFieldType { .SFFloat }

   // Construction
   
   public override init ()
   {
      value = 0
   }

   public init (wrappedValue : Value)
   {
      value = wrappedValue
   }
   
   public final override func copy () -> SFFloat { SFFloat (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFFloat else { return }
      
      value = field .value
   }
}
