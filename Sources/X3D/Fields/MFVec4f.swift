//
//  MFVec4f.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFVec4f :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Vector4f
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFVec4f { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFVec4f" }
   internal final override class var type     : X3DFieldType { .MFVec4f }

   // Construction
   
   public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFVec4f { MFVec4f (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFVec4f else { return }

      wrappedValue = field .wrappedValue
   }
}
