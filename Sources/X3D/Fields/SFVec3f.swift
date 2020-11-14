//
//  SFVec3f.swift
//  X3D
//
//  Created by Holger Seelig on 09.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class SFVec3f :
   X3DField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Value = Vector3f
   
   // Property wrapper handling
   
   public final var projectedValue : SFVec3f { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFVec3f" }
   internal final override class var type     : X3DFieldType { .SFVec3f }

   // Construction
   
   public override init ()
   {
      self .wrappedValue = Vector3f .zero
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFVec3f { SFVec3f (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFVec3f else { return }
      
      wrappedValue = field .wrappedValue
   }
}
