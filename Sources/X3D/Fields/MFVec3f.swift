//
//  MFVec3f.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFVec3f :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Vector3f
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFVec3f { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFVec3f" }
   internal final override class var type     : X3DFieldType { .MFVec3f }

   // Construction
   
   public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFVec3f { MFVec3f (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFVec3f else { return }

      wrappedValue = field .wrappedValue
   }
}
