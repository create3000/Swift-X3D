//
//  SFVec2d.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFVec2d :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Vector2d
   
   // Property wrapper handling
   
   public final var projectedValue : SFVec2d { self }
   public final var wrappedValue : Value { get { value } set { value = newValue; addEvent () } }
   private final var value : Value

   // Common properties
   
   internal final override class var typeName : String { "SFVec2d" }
   internal final override class var type     : X3DFieldType { .SFVec2d }

   // Construction
   
   public override init ()
   {
      value = Vector2d .zero
   }

   public init (wrappedValue : Value)
   {
      value = wrappedValue
   }
   
   public final override func copy () -> SFVec2d { SFVec2d (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFVec2d else { return }
      
      value = field .value
   }
}
