//
//  MFBool.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFBool :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Bool
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFBool { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFBool" }
   internal final override class var type     : X3DFieldType { .MFBool }

   // Construction
   
   public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFBool { MFBool (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFBool else { return }

      wrappedValue = field .wrappedValue
   }
}
