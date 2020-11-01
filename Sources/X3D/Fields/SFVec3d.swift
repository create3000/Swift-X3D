//
//  SFVec3d.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFVec3d :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Vector3d
   
   // Property wrapper handling
   
   public final var projectedValue : SFVec3d { self }
   public final var wrappedValue : Value { get { value } set { value = newValue; addEvent () } }
   private final var value : Value

   // Common properties
   
   public final override class var typeName : String { "SFVec3d" }
   public final override class var type     : X3DFieldType { .SFVec3d }

   // Construction
   
   public override init ()
   {
      value = Vector3d .zero
   }

   public init (wrappedValue : Value)
   {
      value = wrappedValue
   }
   
   public final override func copy () -> SFVec3d { SFVec3d (wrappedValue: value) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFVec3d else { return }
      
      value = field .value
   }
}
