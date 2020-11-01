//
//  SFMatrix4f.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFMatrix4f :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Matrix4f
   
   // Property wrapper handling
   
   public final var projectedValue : SFMatrix4f { self }
   public final var wrappedValue : Value { get { value } set { value = newValue; addEvent () } }
   private final var value : Value

   // Common properties
   
   public final override class var typeName : String { "SFMatrix4f" }
   public final override class var type     : X3DFieldType { .SFMatrix4f }

   // Construction
   
   public override init ()
   {
      value = Matrix4f .identity
   }

   public init (wrappedValue : Value)
   {
      value = wrappedValue
   }
   
   public final override func copy () -> SFMatrix4f { SFMatrix4f (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFMatrix4f else { return }
      
      value = field .value
   }
}
