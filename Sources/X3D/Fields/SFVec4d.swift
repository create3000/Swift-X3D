//
//  SFVec4d.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFVec4d :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Vector4d
   
   // Property wrapper handling
   
   public final var projectedValue : SFVec4d { self }
   public final var wrappedValue : Value { get { value } set { value = newValue; addEvent () } }
   private final var value : Value

   // Common properties
   
   public final override class var typeName : String { "SFVec4d" }
   public final override class var type     : X3DFieldType { .SFVec4d }

   // Construction
   
   public override init ()
   {
      value = Vector4d .zero
   }

   public init (wrappedValue : Value)
   {
      value = wrappedValue
   }
   
   public final override func copy () -> SFVec4d { SFVec4d (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFVec4d else { return }
      
      value = field .value
   }
}
