//
//  SFMatrix3f.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFMatrix3f :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Matrix3f
   
   // Property wrapper handling
   
   public final var projectedValue : SFMatrix3f { self }
   public final var wrappedValue : Value { get { value } set { value = newValue; addEvent () } }
   private final var value : Value

   // Common properties
   
   internal final override class var typeName : String { "SFMatrix3f" }
   internal final override class var type     : X3DFieldType { .SFMatrix3f }

   // Construction
   
   public override init ()
   {
      value = Matrix3f .identity
   }

   public init (wrappedValue : Value)
   {
      value = wrappedValue
   }
   
   public final override func copy () -> SFMatrix3f { SFMatrix3f (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFMatrix3f else { return }
      
      value = field .value
   }
}
