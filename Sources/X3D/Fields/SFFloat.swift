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
   public final var wrappedValue : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFFloat" }
   internal final override class var type     : X3DFieldType { .SFFloat }

   // Construction
   
   public override init ()
   {
      self .wrappedValue = 0
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFFloat { SFFloat (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFFloat else { return }
      
      wrappedValue = field .wrappedValue
   }
}
