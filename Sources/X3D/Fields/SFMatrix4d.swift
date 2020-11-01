//
//  SFMatrix4d.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFMatrix4d :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Matrix4d
   
   // Property wrapper handling
   
   public final var projectedValue : SFMatrix4d { self }
   public final var wrappedValue : Value { get { value } set { value = newValue; addEvent () } }
   private final var value : Value

   // Common properties
   
   public final override class var typeName : String { "SFMatrix4d" }
   public final override class var type     : X3DFieldType { .SFMatrix4d }

   // Construction
   
   public override init ()
   {
      value = Matrix4d .identity
   }

   public init (wrappedValue : Value)
   {
      value = wrappedValue
   }
   
   public final override func copy () -> SFMatrix4d { SFMatrix4d (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFMatrix4d else { return }
      
      value = field .value
   }
}
