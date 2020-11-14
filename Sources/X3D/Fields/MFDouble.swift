//
//  MFDouble.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFDouble :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Double
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFDouble { self }
   public final var wrappedValue : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFDouble" }
   internal final override class var type     : X3DFieldType { .MFDouble }

   // Construction
   
   public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFDouble { MFDouble (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFDouble else { return }

      wrappedValue = field .wrappedValue
   }
}
