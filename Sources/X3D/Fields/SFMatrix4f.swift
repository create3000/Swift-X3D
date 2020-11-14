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
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "SFMatrix4f" }
   internal final override class var type     : X3DFieldType { .SFMatrix4f }

   // Construction
   
   public override init ()
   {
      self .wrappedValue = Matrix4f .identity
   }

   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> SFMatrix4f { SFMatrix4f (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? SFMatrix4f else { return }
      
      wrappedValue = field .wrappedValue
   }
}
