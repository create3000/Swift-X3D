//
//  MFColorRGBA.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

@propertyWrapper
public final class MFColorRGBA :
   X3DArrayField,
   X3DFieldInterface
{
   // Member types
   
   public typealias Element = Color4f
   public typealias Value   = [Element]

   // Property wrapper handling
   
   public final var projectedValue : MFColorRGBA { self }
   public final var wrappedValue   : Value { didSet { addEvent () } }

   // Common properties
   
   internal final override class var typeName : String { "MFColorRGBA" }
   internal final override class var type     : X3DFieldType { .MFColorRGBA }

   // Construction
   
   required public override init ()
   {
      self .wrappedValue = Value ()
   }
   
   public init (wrappedValue : Value)
   {
      self .wrappedValue = wrappedValue
   }
   
   public final override func copy () -> MFColorRGBA { MFColorRGBA (wrappedValue: wrappedValue) }

   // Value handling
   
   internal final override func set (value field : X3DField)
   {
      guard let field = field as? MFColorRGBA else { return }

      wrappedValue = field .wrappedValue
   }
}
