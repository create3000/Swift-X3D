//
//  SFRotation.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFRotation :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Rotation4f
   
   // Property wrapper handling
   
   public final var projectedValue : SFRotation { self }
   public final var wrappedValue : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFRotation" }
   internal final override class var type     : X3DFieldType { .SFRotation }

   // Construction
   
   public override init ()
   {
      self .wrappedValue = Rotation4f .identity
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFRotation { SFRotation (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFRotation else { return }
      
      wrappedValue = field .wrappedValue
   }
}
